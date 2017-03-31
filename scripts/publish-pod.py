import ConfigParser
import os
import sys
import subprocess
import tarfile

import oss2
from retrying import retry


def main(argv):
    adapters = []
    config = ConfigParser.ConfigParser()
    config.read('adapters.ini')
    for adapter_name in config.sections():
        third_party_sdk_dependency = config.get(adapter_name, 'third_party_sdk_dependency')
        version = config.get(adapter_name, 'version')
        extra = config.get(adapter_name, 'extra') if config.has_option(adapter_name, 'extra') else ''
        adapter = Adapter(adapter_name, third_party_sdk_dependency, version, extra=extra)
        adapters.append(adapter)

    yumi_mediation_sdk_version = '>= 1.6.41'

    if os.environ['FRAMEWORK'] == 'YumiMediationSDK':
        YumiMediationSDK = 'YumiMediationSDK'
        print "==========select public sdk=========";
    elif os.environ['FRAMEWORK'] == 'YumiMediationSDK_Zplay' :
        YumiMediationSDK = 'YumiMediationSDK_Zplay'
        print "==========select Zplay sdk==========";

    for adapter in adapters:
        podspec_name = 'YumiMediation%s' % adapter.name
        if os.environ['FRAMEWORK'] == 'YumiMediationSDK_Zplay' :
            podspec_name = 'YumiMediation%s_Zplay' % adapter.name
            print "========== podspec_name:%s ==========" %podspec_name
        generate_podspec_for_packaging(podspec_name, adapter.name, yumi_mediation_sdk_version, YumiMediationSDK)
        package(podspec_name, adapter.name)
        compressed_filename = compress(podspec_name, adapter.version)
        remote_filename = 'iOS/YumiMediationAdapters/%s' % compressed_filename
        upload_to_oss(compressed_filename, remote_filename)
        source = "{ :http => 'http://ad-sdk.oss-cn-beijing.aliyuncs.com/%s' }" % remote_filename
        generate_podspec_for_publishing(podspec_name, adapter, source, yumi_mediation_sdk_version, YumiMediationSDK)
        publish_pod(podspec_name)


class Adapter:
    def __init__(self, name, third_party_sdk_dependency, version, extra=''):
        self.name = name
        self.third_party_sdk_dependency = third_party_sdk_dependency
        self.version = version
        self.extra = extra


def retry_if_pod_not_accessible(exception):
    key = 'Source code for your Pod was not accessible to CocoaPods Trunk'
    return key in str(exception)


def generate_podspec_for_packaging(podspec_name, name, yumi_mediation_sdk_version,YumiMediationSDK):
    with open('podspec-template-for-packaging', 'r') as template:
        values = {
            'podspec_name': podspec_name,
            'name': name,
            'yumi_mediation_sdk_version': yumi_mediation_sdk_version,
            'YumiMediationSDK': YumiMediationSDK
        }
        podspec_data = template.read() % values
        with open(podspec_filename_from_podspec_name(podspec_name), 'w') as podspec:
            podspec.write(podspec_data)


def package(podspec_name, name):
    podspec_filename = podspec_filename_from_podspec_name(podspec_name)
    cmd = 'pod package %s --force --embedded --no-mangle --exclude-deps --subspecs=%s' % (podspec_filename, name)
    code = subprocess.call(cmd, shell=True)
    if code is not 0:
        raise Exception('pod package failed')


def compress(podspec_name, version):
    compressed_filename = '%s-%s.tar.bz2' % (podspec_name, version)
    framework = '{0}-0.0.1/ios/{0}.embeddedframework'.format(podspec_name)
    with tarfile.open(compressed_filename, 'w:bz2') as tar:
        tar.add(framework, arcname=podspec_name)
    return compressed_filename


@retry(stop_max_attempt_number=5)
def upload_to_oss(local_filename, remote_filename):
    auth = oss2.Auth(os.environ['OSS_KEY_ID'], os.environ['OSS_KEY_SECRET'])
    endpoint = 'http://oss-cn-beijing.aliyuncs.com'
    bucket = oss2.Bucket(auth, endpoint, 'ad-sdk')
    bucket.put_object_from_file(remote_filename, local_filename)


def generate_podspec_for_publishing(podspec_name, adapter, source, yumi_mediation_sdk_version,YumiMediationSDK):
    with open('podspec-template-for-publishing', 'r') as template:
        values = {
            'podspec_name': podspec_name,
            'name': adapter.name,
            'version': adapter.version,
            'source': source,
            'yumi_mediation_sdk_version': yumi_mediation_sdk_version,
            'third_party_sdk_dependency': adapter.third_party_sdk_dependency,
            'extra': adapter.extra,
            'YumiMediationSDK': YumiMediationSDK
        }
        podspec_data = template.read() % values
        with open(podspec_filename_from_podspec_name(podspec_name), 'w') as podspec:
            podspec.write(podspec_data)


@retry(retry_on_exception=retry_if_pod_not_accessible, stop_max_attempt_number=5)
def publish_pod(podspec_name):
    cmd = 'pod trunk push %s --allow-warnings' % podspec_filename_from_podspec_name(podspec_name)
    code = subprocess.call(cmd, shell=True)
    if code is not 0:
        raise Exception('pod trunk failed')


def podspec_filename_from_podspec_name(podspec_name):
    return '%s.podspec' % podspec_name


if __name__ == "__main__":
    if os.environ['TRAVIS_PULL_REQUEST'] != 'false' or os.environ['TRAVIS_BRANCH'] != 'production':
        print('we only publish pod in non-pull-request production branch')
        sys.exit(0)

    main(sys.argv)
