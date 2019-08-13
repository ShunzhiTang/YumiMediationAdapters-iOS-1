#
# Be sure to run `pod lib lint YumiMediationAdapters.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YumiMediationAdapters'
  s.version          = '1.0.0'
  s.summary          = 'Yumi Mediation Adapters.'
  s.description      = 'This is the Yumi Mediation Adapters. Please proceed to http://developers.yumimobi.com/IosSdk/index for more information.'
  s.homepage         = 'http://developers.yumimobi.com/IosSdk/index'
  s.license          = 'Custom'
  s.author           = { 'zplay sdk team' => 'ad-client@zplay.cn' }
  s.source           = { :git => 'git@github.com:yumimobi/YumiMediationAdapters-iOS.git',:tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.dependency 'YumiMediationSDK', '~> 4.2.0'
  s.frameworks = 'Foundation', 'UIKit'

  subspecs = [
    { :name => "AdColony", :version => "3.3.7" },
    { :name => "AdMob", :version => "7.44.0", :has_resource_bundle => true },
    { :name => "AppLovin", :version => "6.7.1" },
    { :name => "Baidu", :version => "4.6.4" },
    { :name => "Chartboost", :version => "8.0.1" },
    { :name => "Facebook", :version => "5.3.2", :has_resource_bundle => true },
    { :name => "Domob", :version => "3.8.0" },
    { :name => "GDT", :version => "4.10.3" ,:has_resource_bundle => true},
    { :name => "InMobi", :version => "8.1.0" },
    { :name => "IronSource", :version => "6.8.3" },
    { :name => "Unity", :version => "3.1.0" },
    { :name => "Vungle", :version => "6.4.2" },
    { :name => "Mintegral", :version => "5.3.3"},
    { :name => "OneWay",:version => "2.1.0"},
    { :name => "InneractiveAdSDK",:version => "7.2.3"},
    { :name => "BytedanceAds",:version => "2.0.1.1"},
    { :name => "ZplayAds",:version => "2.4.2"},
    # { :name => "IQzone",:version => "3.0.2141"},
    { :name => "TapjoySDK",:version => "12.3.1"},
    { :name => "PubNative",:version => "1.3.7"},
  ]

  subspecs.each do |spec|
    name = spec[:name]
    version = spec[:version]
    has_resource_bundle = spec[:has_resource_bundle]

    s.subspec name do |sp|
      if name != "ZplayAds"
        sp.dependency "Yumi#{name}", version
      end
      sp.source_files = "YumiMediationAdapters/#{name}/**/*.{h,m}"

      if has_resource_bundle
        sp.resource_bundles = {
          "YumiMediation#{name}" => ["YumiMediationAdapters/#{name}/resources/*"]
        }
      end
    end
  end
end
