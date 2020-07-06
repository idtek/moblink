package com.example.moblinkexample;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import com.mob.MobSDK;
import com.mob.OperationCallback;
import com.mob.PrivacyPolicy;
import com.mob.moblink.MobLink;


import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class MainActivity extends FlutterActivity {

    public static final String METHOD_CHANNEL = "private.flutter.io/method_channel";
    public static final String METHOD_CHANNEL_SUBMIT_PRIVATE = "private.flutter.io/method_channel_submit_private";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterView(), METHOD_CHANNEL).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        if (call.method.equals("getPrivateContent")) {
                            int para = (int) call.arguments;
                            String content = getPrivateContent(para);
                            if (!TextUtils.isEmpty(content)) {
                                result.success(content);
                            } else {
                                result.error("UNAVAILABLE", "not get private content", null);
                            }
                        } else {
                            result.notImplemented();
                        }
                    }
                }
        );

        new MethodChannel(getFlutterView(), METHOD_CHANNEL_SUBMIT_PRIVATE).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        if (call.method.equals("submitPrivacyGrantResult")) {
                            boolean para = (boolean) call.arguments;
                            Log.e("WWW", " para==" + para);
                            submitPrivacyGrantResult(para, result);
                        } else {
                            result.notImplemented();
                        }
                    }
                }
        );
    }

    /**
     * 获取隐私协议的内容
     */
    String text = null;
    private String getPrivateContent(int i) {
        MobSDK.getPrivacyPolicyAsync(i, new PrivacyPolicy.OnPolicyListener() {
            @Override
            public void onComplete(PrivacyPolicy data) {
                if (data != null) {
                    // 富文本内容
                    text = data.getContent();
                    Log.e("WWW", " 隐私协议内通==" + text);
                }
            }

            @Override
            public void onFailure(Throwable t) {
                // 请求失败
                //Log.e(TAG, "隐私协议查询结果：失败 " + t);
            }
        });
        return text;
    }

    /**
     * 同意隐私协议
     */
    private void submitPrivacyGrantResult(boolean granted, Result result) {
        MobSDK.submitPolicyGrantResult(granted, new OperationCallback<Void>() {
            @Override
            public void onComplete(Void data) {
                Log.e("WWW", "隐私协议授权结果提交：成功 " + data);
                result.success("true");
            }

            @Override
            public void onFailure(Throwable t) {
                Log.e("WWW", "隐私协议授权结果提交：失败: " + t);
                result.error(t.getMessage(), "提交失败", "failed");
            }
        });
    }


    // 必须重写该方法，防止MobLink在某些情景下无法还原
    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        MobLink.updateNewIntent(getIntent(), this);
    }
}
