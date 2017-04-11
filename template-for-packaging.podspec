Pod::Spec.new do |s|
  s.name             = '%(podspec_name)s'
  s.version          = '0.0.1'
  s.summary          = '%(name)s adapter used for mediation with the Yumimobi Ads SDK'
  s.description      = 'This is the Yumi Mediation %(name)s Adapter. Please proceed to http://developers.yumimobi.com/IosSdk/index for more information.'
  s.homepage         = 'http://developers.yumimobi.com/IosSdk/index'
  s.license          = 'Custom'
  s.author           = { 'zplay sdk team' => 'ad-client@zplay.cn' }
  s.source           = { :git => 'git@github.com:yumimobi/YumiMediationAdapters-iOS.git' }

  s.ios.deployment_target = '7.0'
  
  s.frameworks = 'UIKit'

  s.dependency 'YumiMediationSDK', '%(yumi_mediation_sdk_version)s'

  s.subspec 'AdMob' do |sp|
    sp.source_files = 'YumiMediationAdapters/AdMob/*.{h,m}'
    sp.resource_bundles = {
      'YumiMediationAdMob' => ['YumiMediationAdapters/AdMob/**/*.{xib,png}']
    }
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
      'YumiMediationFacebook' => ['YumiMediationAdapters/Facebook/*.{xib,png}']
    }
    sp.dependency 'FBAudienceNetwork', '4.17.0'
  end
end
