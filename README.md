# YumiMediationAdapters

[![Build Status](https://travis-ci.com/yumimobi/YumiMediationAdapters-iOS.svg?token=zqqszx67cUwq3jc4kCzH&branch=master)](https://travis-ci.com/yumimobi/YumiMediationAdapters-iOS)

# Adapters

| Name        | Version | Type    | Key1        | Key2         | Key3 | SmartAdSize |
| ----------- | ------- | ------- | ----------- | ------------ | :--: | ----------- |
| AdMob       | 7.20.0  | B+I+N   | adUnitID    |              |      | ❌           |
| Applovin    | 4.2.1   | V       | sdkKey      |              |      | ❌           |
| Baidu       | 4.5.0   | B+I     | publisherId | AdUnitTag    |      | ❌           |
| Chart boost | 6.6.3   | I       | appId       | appSignature |      | ❌           |
| Facebook    | 4.23.0  | B+I+N   | placementID |              |      | ❌           |
| GDT         | 4.5.7   | B+N     | appkey      | placementId  |      | ❌           |
| Inmobi      | 6.2.1   | B+N+V+I | accountID   | placementID  |      | ❌           |
| StartApp    | 3.4.2   | B+I     | appID       |              |      | ✔️          |
| Unity       | 2.1.0   | I+V     | gameId      | placementId  |      | ❌           |
| AdColony    | 3.1.1   | V       | appID       | zoneID       |      | ❌           |
| Domob       | 3.6.0   | V       | publisherID |              |      | ❌           |
| Ironsource  | 6.6.1.1 | V       | appKey      |              |      | ❌           |
| Vungle      | 4.1.0   | V       | AppId       |              |      | ❌           |

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

