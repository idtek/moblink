import 'dart:async';
import 'package:flutter/services.dart';
import 'package:moblink/moblink_defines.dart';

class Moblink {
  static Moblink _instance;
  MethodChannel _channel;
  EventChannel _eventChannel;
  Function(MLSDKScene scne) moblinkCallBack;
  Function(Object error) moblinkError;

  // 静态、同步、私有访问点
  static Moblink sharedInstance() {
    if (_instance == null) {
      _instance = Moblink();
      _instance._channel = MethodChannel('com.yoozoo.mob/moblink');
      _instance._eventChannel = EventChannel("MOBLINK_TO_FLUTTER");
    }
    return _instance;
  }

  void _onEvent(event) {
    if (moblinkCallBack == null) return;
    MLSDKScene scenes = new MLSDKScene(event["path"] ?? "", event["params"]);
    scenes.mobid = event["mobid"] ?? "";
    scenes.className = event["className"];
    scenes.rawURL = event["rawURL"];
    moblinkCallBack(scenes);
  }

  Future<dynamic> _onError(Object error) {
    print("QQQ _onError");
    print(error);
  }

//get ShareSDK PrivacyPolicy
  static Future<dynamic> getPrivacyPolicy(
      String type, Function(Map data, Map error) result) {
    Map args = {"type": type};
    Future<dynamic> callback = Moblink.sharedInstance()
        ._channel
        .invokeMethod(MobLinkMethods.getPrivacyPolicy.name, args);
    callback.then((dynamic response) {
      print(response);
      if (result != null) {
        result(response["data"], response["error"]);
      }
    });
    return callback;
  }

  ///upload user permissionStatus to Share
  static Future<dynamic> uploadPrivacyPermissionStatus(
      int status, Function(bool success) result) {
    Map args = {"status": status};
    Future<dynamic> callback = Moblink.sharedInstance()
        ._channel
        .invokeMethod(MobLinkMethods.uploadPrivacyPermissionStatus.name, args);
    callback.then((dynamic response) {
      print(response);
      if (result != null) {
        result(response["success"]);
      }
    });
    return callback;
  }

  static Future<dynamic> getMobId(MLSDKScene scene,
      Function(String mobid, String domain, MLSDKError error) result) {
    Map args = {"path": scene.path, "params": scene.params};

    Future<dynamic> callback = Moblink.sharedInstance()
        ._channel
        .invokeMethod(MobLinkMethods.getMobId.name, args);

    callback.then((dynamic response) {
      if (result != null) {
        result(response["mobid"], response["domain"],
            MLSDKError(rawData: response["error"]));
      }
    });
    return callback;
  }

  static Future restoreScene(Function(MLSDKScene scene) callback) async {
    Moblink.sharedInstance()._eventChannel.receiveBroadcastStream().listen(
        Moblink.sharedInstance()._onEvent,
        onError: Moblink.sharedInstance()._onError);
    Moblink.sharedInstance()
        ._channel
        .invokeMethod(MobLinkMethods.restoreScene.name);
    Moblink.sharedInstance().moblinkCallBack = callback;
  }

  static Future<dynamic> restoreScene_Android() async {
    try {
      dynamic response =
          await _instance._channel.invokeMethod(MobLinkMethods.restoreScene.name);
      print(response);
      MLSDKScene scenes =
          new MLSDKScene(response["path"] ?? "", response["params"]);
      scenes.mobid = response["mobid"] ?? "";
      scenes.className = response["className"];
      scenes.rawURL = response["rawURL"];
      return scenes;
    } catch (e) {}
  }
}

class MLSDKScene {
  // path (required)
  String path;

  // custom parameter (Optional)
  Map params;

  // mobid（Readonly）
  String mobid;

  // class name of the corresponding path（Readonly）
  String className;

  // original link（Readonly）
  String rawURL;

  // create scene
  MLSDKScene(this.path, this.params);
}
