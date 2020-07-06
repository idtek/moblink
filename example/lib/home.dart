import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:moblink/moblink.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const EventChannel _eventChannel =
      const EventChannel('JAVA_TO_FLUTTER');

  static const MethodChannel _methodChannel =
      const MethodChannel('private.flutter.io/method_channel');

  static const MethodChannel _methodChannel_submit =
  const MethodChannel('private.flutter.io/method_channel_submit_private');

  static const platform = const MethodChannel('demo.gawkat.com/info');

  @override
  void initState() {
    super.initState();
    Moblink.uploadPrivacyPermissionStatus(1, (bool success) {});

    // 是安卓系统，Android场景还原的实现
    /*if (defaultTargetPlatform == TargetPlatform.android) {

    }*/

    //app后台杀死时候的还原
    Moblink.restoreScene((MLSDKScene scene) {
      showAlert('要还原的路径为：' + scene.className, context);
      print('要还原的路径为：' + scene.className);
    });
    // 监听开始(传递监听到原生端，用户监听场景还原的数据回传回来)
    _eventChannel
        .receiveBroadcastStream()
        .listen(_onEvent, onError: _onError);
  }

  /// @param 隐私协议返回数据的格式
  /// POLICY_TYPE_URL = 1
  /// POLICY_TYPE_TXT = 2
  Future<void> _getPrivateContent(flutterPara) async {
    String result;
    try {
      result = await _methodChannel.invokeMethod('getPrivateContent', flutterPara);
      print('QQQ隐私协议内容：' + result);
      showAlert('隐私协议内容：$result', context);
    } on PlatformException catch (e) {}

    setState(() {
     // _privateContent = result;
    });
  }

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

  //app存在后台时候的还原
  void _onEvent(Object event) {
    print('返回的内容: $event');
    if (null != event) {
      showAlert('要还原的路径为[活着]：$event', context);
    }
  }

  void _onError(Object error) {
    print('返回的错误');
  }

  void getMobId(BuildContext context) {
    // 设置参数
    MLSDKScene scene =
        MLSDKScene('/scene/a', {'param1': '123', 'param2': '456'});
    // 传入 scene , 获取 mobid
    Moblink.getMobId(scene, (String mobid, String domain, MLSDKError error) {
      print('QQQ mobid回调');
      if (mobid != null) {
        print('QQQ 得到mobid：' + mobid);
        showAlert(mobid, context);
      }
    });
  }

  void getShortUrl(BuildContext context) {
    MLSDKScene scene =
        MLSDKScene('/scene/b', {'param1': '456', 'param2': '789'});
    Moblink.getMobId(scene, (String mobid, String domain, MLSDKError error) {
      if (mobid != null) {
        print('分享短链:' + domain + mobid);
        showAlert(domain + mobid, context);
      }
    });
  }

  void goPrivateView(BuildContext context) {
    _getPrivateContent(1);
  }

  void setPrivateState(BuildContext context){
    _setPrivateState(true);
  }

  void showAlert(String text, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
                title: new Text("提示"),
                content: new Text(text),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ]));
  }

  Widget _creatRow(String methodName, String methodDes, Function method,
      BuildContext context) {
    return new GestureDetector(
      onTap: () {
        method(context);
      },
      child: new Container(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        width: MediaQuery.of(context).size.width,
        color: Colors.grey.withAlpha(10),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // padding: const EdgeInsets.only(bottom: 2.0),
          children: [
            new Container(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: new Text(
                methodName,
                style: new TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            new Text(
              methodDes,
              style: new TextStyle(
                color: Colors.grey[500],
              ),
            ),
            new Container(
              padding: const EdgeInsets.only(top: 5.0),
              child: new Container(
                padding: const EdgeInsets.only(top: 0.33),
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// @param 隐私协议返回数据的格式
  /// POLICY_TYPE_URL = 1
  /// POLICY_TYPE_TXT = 2
  void getPrivacyPolicyUrl(BuildContext context) {
    Moblink.getPrivacyPolicy("1", (Map data, Map error) {
      String policyData, errorStr;

      print("==============>getPrivacyPolicyUrl ");
      if (data != null) {
        policyData = data["data"];
        print("==============>policyData " + policyData);
      }

      if (error != null) {
        errorStr = error["error"];
        print("==============>errorStr " + errorStr);
      }

      if (policyData != null) {
        showAlert("隐私协议" + policyData, context);
      } else if (errorStr != null) {
        showAlert("隐私协议" + errorStr, context);
      } else {
        showAlert("隐私协议" + "获取隐私协议失败", context);
      }
    });
  }

  /// 0 ===> 不同意隐私政策
  /// 1 ===> 同意
  void submitPrivacyGrantResult(BuildContext context) {
    Moblink.uploadPrivacyPermissionStatus(1, (bool success) {
      if (success == true) {
        showAlert("隐私协议授权提交结果" + "成功", context);
      } else {
        showAlert("隐私协议授权提交结果" + "失败", context);
      }
    });
  }

  ///隐私二次确认框开关设置
  /// 1 ===> 同意
  /// 0 ===> 不同意
  void setAllowDialog(BuildContext context) {}

  /// 自定义隐私二次确认框UI
  void setPrivacyUI(BuildContext context) {
    int BackgroundColorId = 1001;
    int PositiveBtnColorId = 1002;
    int setNegativeBtnColorId = 1003;

    List<int> operationButtonColors = new List<int>();
    operationButtonColors.add(PositiveBtnColorId);
    operationButtonColors.add(setNegativeBtnColorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: const Text('MobLink Plugin'),
      ),
      body: new ListView(
        padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
        children: <Widget>[
          _creatRow("生成MobId", "path: /demo/a", getMobId, context),
          _creatRow("生成短链", "path: /demo/b", getShortUrl, context),
          _creatRow("Android隐私协议相关", "获取隐私协议内容", goPrivateView, context),
          _creatRow("Android设置隐私协议的状态", "设置隐私协议的状态", setPrivateState, context),
          _creatRow("获取隐私协议", "1：url 2.内容", getPrivacyPolicyUrl, context),
          _creatRow(
              "设置隐私协议状态", "请先设置隐私协议状态", submitPrivacyGrantResult, context),
        ],
      ),
    );
  }
}
