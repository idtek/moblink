# moblink_example

### supported original MobLink minimum version:
* [iOS](https://github.com/MobClub/MobLinkPro-for-iOS) - V3.0.0
* [Android](https://github.com/MobClub/MobLink-for-Android) - V3.0.0

## Getting Started

* import library

```
import 'package:moblink/moblink.dart';
```
* get mobid
	
```
// 设置参数
	MLSDKScene scene =
        MLSDKScene('/demo/a', {'param1': '123', 'param2': '456'});
    // 传入 scene , 获取 mobid
    Moblink.getMobId(scene, (String mobid, String domain, MLSDKError error) {
      if (mobid != null) {
        print('得到mobid：' + mobid);
        // do something
      }
    });
```

* get restore scene callback

```
// 场景还原的回调
    Moblink.restoreScene((MLSDKScene scene) {
      // 根据场景，手动设置跳转
      print('要还原的路径为：' + scene.path);
		// do restore scene
    });
```