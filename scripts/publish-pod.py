import os
import sys
import subprocess
import tarfile

import oss2


TAG = os.environ.get('TRAVIS_TAG')

def main(argv):
    yumi_mediation_sdk_version = '~> 0.8.9'
    adapters = [
        # Adapter('AdColony', '"AdColony", "2.6.3"', '2.6.3.0'),
        Adapter('AdMob', '"Google-Mobile-Ads-SDK", "7.18.0"', '7.8.1.0'),
        Adapter('AppLovin', '"YumiAppLovinSDK", "3.4.3"', '3.4.3.0'),
        Adapter('Baidu', '"YumiBaiduSDK", "4.5.0"', '4.5.0.0'),
        Adapter('Chartboost', '"ChartboostSDK", "6.6.1"', '6.6.1.0'),
        Adapter('Facebook', '"FBAudienceNetwork", "4.17.0"', '4.17.0.0'),
        Adapter('GDT', '"YumiGDTSDK", "4.5.5"', '4.5.5.0'),
        Adapter('InMobi', '"InMobiSDK", "6.0.0"', '6.0.0.0'),
        Adapter('Mopub', '"YumiMopubSDK", "4.11.1"', '4.11.1.0'),
        Adapter('StartApp', '"YumiStartAppSDK", "3.4.1"', '3.4.1.0'),
        Adapter('Unity', '"YumiUnitySDK", "2.0.0"', '2.0.0.0'),
        # Adapter('Vungle', '"VungleSDK-iOS", "4.0.8"', '4.0.8.0')
    ]
    for adapter in adapters:
        podspec_name = 'YumiMediation%s' % adapter.name
        generate_podspec_for_packaging(podspec_name, adapter.name, yumi_mediation_sdk_version)
        package(podspec_name, adapter.name)
        compressed_filename = compress(podspec_name, adapter.version)
        remote_filename = 'iOS/YumiMediationAdapters/%s' % compressed_filename
        upload_to_oss(compressed_filename, remote_filename)
        source = "{ :http => 'http://adsdk.yumimobi.com/%s' }" % remote_filename
        generate_podspec_for_publishing(podspec_name, adapter, source, yumi_mediation_sdk_version)
        publish_pod(podspec_name)


class Adapter:
    def __init__(self, name, third_party_sdk_dependency, version):
        self.name = name
        self.third_party_sdk_dependency = third_party_sdk_dependency
        self.version = version


def generate_podspec_for_packaging(podspec_name, name, yumi_mediation_sdk_version):
    with open('podspec-template-for-packaging', 'r') as template:
        values = {
            'podspec_name': podspec_name,
            'tag': TAG,
            'name': name,
            'yumi_mediation_sdk_version': yumi_mediation_sdk_version
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
    framework = '{0}-{1}/ios/{0}.embeddedframework/{0}.framework'.format(podspec_name, TAG)
    with tarfile.open(compressed_filename, 'w:bz2') as tar:
        tar.add(framework, arcname='{0}/{0}.framework'.format(podspec_name))
    return compressed_filename


def upload_to_oss(local_filename, remote_filename):
    auth = oss2.Auth(os.environ['OSS_KEY_ID'], os.environ['OSS_KEY_SECRET'])
    endpoint = 'http://oss-cn-beijing.aliyuncs.com'
    bucket = oss2.Bucket(auth, endpoint, 'ad-sdk')
    bucket.put_object_from_file(remote_filename, local_filename)


def generate_podspec_for_publishing(podspec_name, adapter, source, yumi_mediation_sdk_version):
    pass


def publish_pod(podspec_name):
    pass


def podspec_filename_from_podspec_name(podspec_name):
    return '%s.podspec' % podspec_name


if __name__ == "__main__":
    if not TAG:
        print('this is not a tag, exit here...')
        sys.exit(0)

    main(sys.argv)
