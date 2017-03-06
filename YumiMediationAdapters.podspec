#
# Be sure to run `pod lib lint YumiMediationAdapters.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YumiMediationAdapters'
  s.version          = '0.4.5'
  s.summary          = 'Yumi Mediation Adapters.'
  s.description      = 'This is the Yumi Mediation Adapters. Please proceed to http://developers.yumimobi.com/IosSdk/index for more information.'

  s.homepage         = 'https://github.com/yumimobi/YumiMediationAdapters-iOS'
  s.license          = 'Custom'
  s.author           = { 'zplay sdk team' => 'ad-client@zplay.cn' }
  s.source           = { :git => 'git@github.com:yumimobi/YumiMediationAdapters-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'

  s.dependency 'YumiMediationSDK', '~> 0.8.9'

  s.subspec 'AdMob' do |sp|
    sp.source_files = 'YumiMediationAdapters/AdMob/*.{h,m}'
    sp.dependency 'Google-Mobile-Ads-SDK', '7.18.0'
  end

  s.subspec 'InMobi' do |sp|
    sp.source_files = 'YumiMediationAdapters/InMobi/*.{h,m}'
    sp.dependency 'InMobiSDK', '6.0.0'
  end

  # s.subspec 'Vungle' do |sp|
  #   sp.source_files = 'YumiMediationAdapters/Vungle/*.{h,m}'
  #   sp.dependency 'VungleSDK-iOS', '= 4.0.8'
  # end

  # s.subspec 'AdColony' do |sp|
  #   sp.source_files = 'YumiMediationAdapters/AdColony/*.{h,m}'
  #   sp.dependency 'AdColony', '= 2.6.3'
  # end

  s.subspec 'Chartboost' do |sp|
    sp.source_files = 'YumiMediationAdapters/Chartboost/*.{h,m}'
    sp.dependency 'ChartboostSDK', '6.6.1'
  end

  s.subspec 'AppLovin' do |sp|
    sp.source_files = 'YumiMediationAdapters/AppLovin/*.{h,m}'
    sp.dependency 'YumiAppLovinSDK', '3.4.3'
  end

  s.subspec 'GDT' do |sp|
    sp.source_files = 'YumiMediationAdapters/GDT/*.{h,m}'
    sp.dependency 'YumiGDTSDK', '4.5.5'
  end

  s.subspec 'Mopub' do |sp|
    sp.source_files = 'YumiMediationAdapters/Mopub/*.{h,m}'
    sp.dependency 'YumiMopubSDK', '4.11.1'
  end

  s.subspec 'StartApp' do |sp|
    sp.source_files = 'YumiMediationAdapters/StartApp/*.{h,m}'
    sp.dependency 'YumiStartAppSDK', '3.4.1'
  end

  s.subspec 'Unity' do |sp|
    sp.source_files = 'YumiMediationAdapters/Unity/*.{h,m}'
    sp.dependency 'YumiUnitySDK', '2.0.0'
  end

  s.subspec 'Baidu' do |sp|
    sp.source_files = 'YumiMediationAdapters/Baidu/*.{h,m}'
    sp.dependency 'YumiBaiduSDK', '4.5.0'
  end

  s.subspec 'Facebook' do |sp|
    sp.source_files = 'YumiMediationAdapters/Facebook/*.{h,m}'
    sp.resource_bundles = {
      'YumiFacebookAdapter' => ['YumiMediationAdapters/Facebook/*.{nib,png}']
    }
    sp.dependency 'FBAudienceNetwork', '4.17.0'
  end

end
