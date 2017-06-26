# YumiMediationAdapters

[![Build Status](https://travis-ci.com/yumimobi/YumiMediationAdapters-iOS.svg?token=zqqszx67cUwq3jc4kCzH&branch=master)](https://travis-ci.com/yumimobi/YumiMediationAdapters-iOS)

# Adapters

| Name        | Version | Type    | Key1      | Key2        | Key3 | SmartAdSize |
| ----------- | ------- | ------- | --------- | ----------- | :--: | ----------- |
| AdMob       | 7.20.0  | B | adUnitID  |             |      | ✔️          |
| Applovin    |         |         |           |             |      |             |
| Baidu       |     4.5.0    |  B       |           |             |      |           ✔️  |
| Chart boost |         |         |           |             |      |             |
| Facebook    |    4.23.0    |  B       |           |             |      |          ✔️   |
| GDT         |         |         |           |             |      |             |
| Inmobi      | 6.2.1   | B | accountID | placementID |      | ❌           |
| StartApp    |         |         |           |             |      |             |
| Unity       |         |         |           |             |      |             |
| Mopub       |         |         |           |             |      |             |
| AdColony    |         |         |           |             |      |             |
| Domob       |         |         |           |             |      |             |
| Ironsource  |         |         |           |             |      |             |
| Vungle      |         |         |           |             |      |             |

| ShortName | FullName     |
| --------- | ------------ |
| B         | Banner       |
| I         | Interstitial |
| V         | Video        |
| N         | Native       |



### Develop

```sh
# generate adapter template
$ fastlane generate name:Chartboost adtype:Video request_type:SDK
$ fastlane generate name:GDT adtype:Banner request_type:API

# go back to YumiMediationSDK-iOS workspace and start integrating
```

