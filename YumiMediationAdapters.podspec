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
  s.dependency 'YumiMediationSDK', '~> 3.5.0'
  s.frameworks = 'Foundation', 'UIKit'

  subspecs = [
    { :name => "AdColony", :version => "3.3.6" },
    { :name => "AdMob", :version => "7.30.0", :has_resource_bundle => true },
    { :name => "AppLovin", :version => "5.0.2" },
    { :name => "Baidu", :version => "4.5.0.5" },
    { :name => "Chartboost", :version => "7.3.0" },
    { :name => "Facebook", :version => "5.1.0", :has_resource_bundle => true },
    { :name => "Domob", :version => "3.8.0" },
    { :name => "GDT", :version => "4.8.1" ,:has_resource_bundle => true},
    { :name => "InMobi", :version => "7.2.1" },
    { :name => "IronSource", :version => "6.7.10" },
    { :name => "Unity", :version => "2.3.0" },
    { :name => "Vungle", :version => "6.2.0" },
    { :name => "Mintegral", :version => "3.9.1"},
    { :name => "OneWay",:version => "2.1.0"},
    { :name => "PlayableAds",:version => "2.3.0"},
  ]

  subspecs.each do |spec|
    name = spec[:name]
    version = spec[:version]
    has_resource_bundle = spec[:has_resource_bundle]

    s.subspec name do |sp|
      if name != "PlayableAds"
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
