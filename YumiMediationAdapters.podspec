Pod::Spec.new do |s|
  s.name = 'YumiMediationAdapters'
  s.version = '4.3.0'
  s.summary = 'Yumi Mediation Adapters.'
  s.description = 'This is the Yumi Mediation Adapters. Please proceed to http://developers.yumimobi.com/IosSdk/index for more information.'
  s.homepage = 'http://developers.yumimobi.com/IosSdk/index'
  s.license = 'Custom'
  s.authors = {"zplay sdk team"=>"ad-client@zplay.cn"}
  s.source = {:git => 'git@github.com:yumimobi/YumiMediationAdapters-iOS.git',:tag => s.version.to_s}
  s.platforms = {"ios"=>"8.0"}
  s.dependency 'YumiMediationSDK', '~> 4.3.0'
  s.subspec 'AdColony' do |sp|
    sp.source_files = "YumiMediationAdapters/AdColony/**/*.{h,m}"
    sp.dependency 'YumiAdColony', '3.3.7'
  end
  s.subspec 'AdMob' do |sp|
    sp.source_files = "YumiMediationAdapters/AdMob/**/*.{h,m}"
    sp.dependency 'YumiAdMob', '7.44.0'
    sp.resource_bundles = {'YumiMediationAdMob' => ['YumiMediationAdapters/AdMob/resources/*']}
  end
  s.subspec 'AppLovin' do |sp|
    sp.source_files = "YumiMediationAdapters/AppLovin/**/*.{h,m}"
    sp.dependency 'YumiAppLovin', '6.7.1'
  end
  s.subspec 'Baidu' do |sp|
    sp.source_files = "YumiMediationAdapters/Baidu/**/*.{h,m}"
    sp.dependency 'YumiBaidu', '4.6.5'
  end
  s.subspec 'Chartboost' do |sp|
    sp.source_files = "YumiMediationAdapters/Chartboost/**/*.{h,m}"
    sp.dependency 'YumiChartboost', '8.0.1'
  end
  s.subspec 'Facebook' do |sp|
    sp.source_files = "YumiMediationAdapters/Facebook/**/*.{h,m}"
    sp.dependency 'YumiFacebook', '5.4.0'
    sp.resource_bundles = {'YumiMediationFacebook' => ['YumiMediationAdapters/Facebook/resources/*']}
  end
  s.subspec 'Domob' do |sp|
    sp.source_files = "YumiMediationAdapters/Domob/**/*.{h,m}"
    sp.dependency 'YumiDomob', '3.8.0'
  end
  s.subspec 'GDT' do |sp|
    sp.source_files = "YumiMediationAdapters/GDT/**/*.{h,m}"
    sp.dependency 'YumiGDT', '4.10.3'
    sp.resource_bundles = {'YumiMediationGDT' => ['YumiMediationAdapters/GDT/resources/*']}
  end
  s.subspec 'InMobi' do |sp|
    sp.source_files = "YumiMediationAdapters/InMobi/**/*.{h,m}"
    sp.dependency 'YumiInMobi', '8.1.0'
  end
  s.subspec 'IronSource' do |sp|
    sp.source_files = "YumiMediationAdapters/IronSource/**/*.{h,m}"
    sp.dependency 'YumiIronSource', '6.8.3'
  end
  s.subspec 'Unity' do |sp|
    sp.source_files = "YumiMediationAdapters/Unity/**/*.{h,m}"
    sp.dependency 'YumiUnity', '3.1.0'
  end
  s.subspec 'Vungle' do |sp|
    sp.source_files = "YumiMediationAdapters/Vungle/**/*.{h,m}"
    sp.dependency 'YumiVungle', '6.4.2'
  end
  s.subspec 'Mintegral' do |sp|
    sp.source_files = "YumiMediationAdapters/Mintegral/**/*.{h,m}"
    sp.dependency 'YumiMintegral', '5.3.3'
  end
  s.subspec 'OneWay' do |sp|
    sp.source_files = "YumiMediationAdapters/OneWay/**/*.{h,m}"
    sp.dependency 'YumiOneWay', '2.1.0'
  end
  s.subspec 'InneractiveAdSDK' do |sp|
    sp.source_files = "YumiMediationAdapters/InneractiveAdSDK/**/*.{h,m}"
    sp.dependency 'YumiInneractiveAdSDK', '7.2.3'
  end
  s.subspec 'BytedanceAds' do |sp|
    sp.source_files = "YumiMediationAdapters/BytedanceAds/**/*.{h,m}"
    sp.dependency 'YumiBytedanceAds', '2.0.1.1'
  end
  s.subspec 'ZplayAds' do |sp|
    sp.source_files = "YumiMediationAdapters/ZplayAds/**/*.{h,m}"
  end
  s.subspec 'TapjoySDK' do |sp|
    sp.source_files = "YumiMediationAdapters/TapjoySDK/**/*.{h,m}"
    sp.dependency 'YumiTapjoySDK', '12.3.1'
  end
  s.subspec 'PubNative' do |sp|
    sp.source_files = "YumiMediationAdapters/PubNative/**/*.{h,m}"
    sp.dependency 'YumiPubNative', '1.3.7'
  end
end
