#
# Be sure to run `pod lib lint YumiMediationAdapters.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YumiMediationAdapters'
  s.version          = '0.2.0'
  s.summary          = 'Yumi Mediation Adapters.'
  s.description      = 'This is the Yumi Mediation Adapters 0.2.0. Please proceed to http://developers.yumimobi.com/IosSdk/index for more information.'

  s.homepage         = 'https://github.com/yumimobi/YumiMediationAdapters-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'on99' => 'nanohugh@gmail.com' }
  s.source           = { :git => 'https://github.com/yumimobi/YumiMediationAdapters-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'

  s.dependency 'YumiMediationSDK', '~> 0.4.0'

  s.subspec 'AdMob' do |sp|
    sp.source_files = 'YumiMediationAdapters/AdMob/*.{h,m}'
    sp.dependency 'Google-Mobile-Ads-SDK', '~> 7.0'
  end

  s.subspec 'InMobi' do |sp|
    sp.source_files = 'YumiMediationAdapters/InMobi/*.{h,m}'
    sp.dependency 'InMobiSDK', '~> 6.0.0'
  end

end
