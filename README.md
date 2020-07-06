### 本插件是基于MobLink 对Flutter进行插件扩充支持。目的是方便Flutter开发者更方便地集成使用MobLink。


**插件主页**：[**https://pub.dartlang.org/packages/moblink**](https://pub.dartlang.org/packages/moblink)

**Demo例子**：[**https://github.com/MobClub/MobLink-For-Flutter**](https://github.com/MobClub/MobLink-For-Flutter)

### 开始集成
1.参考 **[Flutter官方插件集成文档](https://pub.dev/packages/moblink)**

- 在 pubspec.yaml 文件中加入下面依赖

		dependencies:
	  		moblink:

- 然后执行：**flutter packages get** 导入package

- 在你的dart工程文件中，导入下面头文件，开始使用

		import 'package:moblink/moblink.dart';

iOS：

平台设置参考  [**iOS集成文档**](http://www.mob.com/wiki/detailed?wiki=Moblink_ios_major_first&id=34)

**实现**
- 第一步集成准备里的第1点申请appkey和appSecret信息
- 第二步配置集成中的1，3点，配置后台选项，以及客户端里URL Scheme和Universal link的配置和Appkey，AppSecret的配置

Android：

平台设置参考 [**Android集成文档**](https://www.mob.com/wiki/detailed?wiki=MobLink_for_Android_Jicheng_pro&id=34)

**实现**
- 第一步按Android集成文档中的第一点注册应用,申请Mob的 AppKey 和 AppSecret;
- 第二步按Android集成文档中的第一点完成集成配置
  1.打开项目根目录的build.gradle，在buildscrip–>dependencies 模块下面添加classpath 'com.mob.sdk:MobSDK:+'，如下所示；
  ```java
  buildscript {
  	repositories {
      	...
  	}

  	dependencies {
      	...
      	classpath 'com.mob.sdk:MobSDK:+'
  	}
  }
  ```
  2.在使用MobLink模块的build.gradle中，添加MobSDK插件和扩展，如下所示：

  ```java
  // 添加插件
  apply plugin: 'com.mob.sdk'
  // 在MobSDK的扩展中注册MobLink的相关信息
  MobSDK {
      appKey "您的Mob-AppKey"
      appSecret "您的Mob-AppSecret"
      MobLink {
          uriScheme "您后台配置的scheme"
          appLinkHost "您后台开启AppLink时生成的Host"
      }
  }
  ```
- 第三步在MainActivity的onCreate中添加以下代码：
  ```
  //导入的包
  import com.mob.moblink.MobLink;
  // 必须重写该方法，防止MobLink在某些情景下无法还原
    @Override
    protected void onNewIntent(Intent intent) {
      super.onNewIntent(intent);
      setIntent(intent);
      MobLink.updateNewIntent(getIntent(), this);
    }
  ```
  ![](http://download.sdk.mob.com/2020/06/03/17/1591176270323/1222_466_60.22.png)

- 第四步创建一个application继承FlutterApplication,在创建的application的onCreate中添加以下代码防止APP杀死进程后无法进行场景还原：

  ```
  //导入的包
  import com.example.moblink.MoblinkPlugin;
  import com.mob.moblink.MobLink;
  //防止MobLink在APP杀死进程后无法还原
  @Override
      public void onCreate() {
          super.onCreate();
          MobLink.setRestoreSceneListener(new MoblinkPlugin.SceneListener());
      }
  ```

  ![](http://download.sdk.mob.com/2020/06/03/17/1591176301154/1412_290_39.11.png)

  **<font color='red'>注意：Android的相关代码在flutter层会报错,但不会影响项目的运行和moblink功能的使用</font>**

 Web：

平台设置参考 [**Web端集成文档**](http://www.mob.com/wiki/detailed?wiki=MobLink_for_Web&id=34)

#### 接口说明:

**（1）获取mobid**

- get mobid

  ```
  // 设置参数
  MLSDKScene scene = MLSDKScene('/demo/a', {'param1': '123', 'param2': '456'});
  // 传入 scene , 获取 mobid
  Moblink.getMobId(scene, (String mobid, String domain, MLSDKError error) {
     if (mobid != null) {
        print('得到mobid：' + mobid);
  	  print('分享短链:' + domain + mobid);
  	  showAlert(domain + mobid, context);
  	    // do something
  	   }
  	});
  ```


**（2）景还原回调**

- get restore scene callback

	    //设置回调通道
	     static const EventChannel _eventChannel =const EventChannel('JAVA_TO_FLUTTER');
	     //监听开始(传递监听到原生端，用户监听场景还原的数据回传回来)
	      _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
	      // 场景还原的回调
	        Moblink.restoreScene((MLSDKScene scene) {
	       // 根据场景，手动设置跳转
	         print('要还原的路径为：' + scene.path);
	         // do restore scene
	           });

**（3）获取mob隐私协议**
- get mob privacy protocol
```
//设置通道
static const MethodChannel _methodChannel =
const MethodChannel('private.flutter.io/method_channel');
// @param 隐私协议返回数据的格式
// flutterPara POLICY_TYPE_URL = 1
// flutterPara POLICY_TYPE_TXT = 2
   Future<void> _getPrivateContent(flutterPara) async {
    String result;
    try {
      result = await _methodChannel.invokeMethod('getPrivateContent', flutterPara);
      print('隐私协议内容：' + result);
      showAlert('隐私协议内容：$result', context);
    } on PlatformException catch (e) {}
    setState(() {
     // _privateContent = result;
    });
  }
```

  **（4）设置隐私协议状态隐私协议**

  - set the privacy protocol status

```
 //设置通道
   static const MethodChannel _methodChannel_submit =
   const MethodChannel('private.flutter.io/method_channel_submit_private');
 //flutterPara设置true或者false
    Future<void> _setPrivateState(flutterPara) async {
    String result;
    try {
      result = await _methodChannel_submit.invokeMethod('submitPrivacyGrantResult', flutterPara);
      print('隐私协议提交成功：' + result);
      showAlert('隐私协议提交成功：$result', context);
    } on PlatformException catch (e) {}
    setState(() {
      // _privateContent = result;
    });
  }
```

