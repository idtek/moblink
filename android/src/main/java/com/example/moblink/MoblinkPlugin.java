package com.example.moblink;

import android.app.Activity;
import android.os.Handler;
import android.text.Html;
import android.text.TextUtils;
import android.util.Log;

import com.mob.MobSDK;
import com.mob.PrivacyPolicy;
import com.mob.moblink.ActionListener;
import com.mob.moblink.MobLink;
import com.mob.moblink.RestoreSceneListener;
import com.mob.moblink.Scene;
import com.mob.moblink.SceneRestorable;
import com.mob.tools.utils.Hashon;
import com.mob.tools.utils.SharePrefrenceHelper;

import java.util.HashMap;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * MoblinkPlugin
 */
public class MoblinkPlugin extends Object implements MethodCallHandler, SceneRestorable {
    private static final String getMobId = "getMobId";
    private static final String restoreScene = "restoreScene";

    private static final String EventChannel = "JAVA_TO_FLUTTER";
    private static EventChannel.EventSink mEventSink;
    private static boolean ismEventSinkNotNull;
    private static Activity activity;
    private static HashMap<String, Object> onReturnSceneDataMap;

    public MoblinkPlugin(Activity activity) {
        //场景还原监听
        MobLink.setRestoreSceneListener(new SceneListener());
    }

    //Java代码
    public static class SceneListener extends Object implements RestoreSceneListener {
        @Override
        public Class<? extends Activity> willRestoreScene(Scene scene) {
            Log.e("WWW", " willRestoreScene==" + new Hashon().fromObject(scene));

            onReturnSceneDataMap = new HashMap<>();
            onReturnSceneDataMap.put("path", scene.getPath());
            onReturnSceneDataMap.put("params", scene.getParams());

            Log.e("WWW", " willRestoreScene[onReturnSceneDataMap]==" + new Hashon().fromObject(onReturnSceneDataMap));

            if (null != mEventSink) {
                Log.e("WWW", " willRestoreScene[onReturnSceneDataMap]==开始回调了传递数据了");
                restoreScene();
                ismEventSinkNotNull = false;
            } else {
                ismEventSinkNotNull = true;
            }
            return null;
        }

        @Override
        public void notFoundScene(Scene scene) {
            //TODO 未找到处理scene的activity时回调
        }

        @Override
        public void completeRestore(Scene scene) {
            // TODO 在"拉起"处理场景的Activity之后调用
        }
    }

    /**
     * 提供给java层传递数据到flutter层的方法
     **/
    public void setEvent(Object data) {
        if (mEventSink != null) {
            mEventSink.success(data);
        } else {
            Log.e("WWW", " ===== FlutterEventChannel.eventSink 为空 需要检查一下 ===== ");
        }
    }

    private void queryPrivacy() {
        // 异步方法
        MobSDK.getPrivacyPolicyAsync(MobSDK.POLICY_TYPE_URL, new PrivacyPolicy.OnPolicyListener() {
            @Override
            public void onComplete(PrivacyPolicy data) {
                if (data != null) {
                    // 富文本内容
                    String text = data.getContent();
                }
            }

            @Override
            public void onFailure(Throwable t) {
                // 请求失败
                //Log.e(TAG, "隐私协议查询结果：失败 " + t);
            }
        });
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        Log.e("WWW", " registerWith[注册过来回传监听的回掉]==");

        final MethodChannel channel = new MethodChannel(registrar.messenger(), "com.yoozoo.mob/moblink");
        channel.setMethodCallHandler(new MoblinkPlugin(registrar.activity()));
        activity = registrar.activity();
        final EventChannel eventChannel = new EventChannel(registrar.messenger(), EventChannel);
        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink eventSink) {
                Log.e("WWW", " registerWith(onListen)[接受到回掉]==");
                mEventSink = eventSink;
                if (ismEventSinkNotNull) {
                    Log.e("WWW", " registerWith[onListen]==开始回调了传递数据了");
                    ismEventSinkNotNull = false;
                    restoreScene();
                }
            }

            @Override
            public void onCancel(Object o) {

            }
        });
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        MobLink.setActivityDelegate(activity, MoblinkPlugin.this);
        switch (call.method) {
            case getMobId:
                getMobId(call, result);
                break;
            case restoreScene:
                restoreScene(result);
                break;
        }
    }

    private void getMobId(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        HashMap<String, Object> params = (HashMap<String, Object>) map.get("params");
        String path = String.valueOf(map.get("path"));

        // 新建场景
        Scene s = new Scene();
        s.path = path;
        s.params = params;

        // 请求场景ID
        MobLink.getMobID(s, new ActionListener() {
            @Override
            public void onResult(Object o) {
                HashMap resposon = new HashMap<String, String>();
                resposon.put("mobid", o);
                resposon.put("domain", "");
                result.success(resposon);
            }

            public void onError(Throwable throwable) {
                result.error(throwable.getMessage().toString(), null, null);
            }
        });
    }

    private void restoreScene(Result result) {
        if (result != null) {
            if (onReturnSceneDataMap != null) {
                mEventSink.success(onReturnSceneDataMap);
                onReturnSceneDataMap = null;
            }
            if (onReturnSceneDataMap != null && onReturnSceneDataMap.size() > 0) {
                if (null != mEventSink) {
                    mEventSink.success(onReturnSceneDataMap);
                } else {
                    new Handler().postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            if (null != mEventSink) {
                                mEventSink.success(onReturnSceneDataMap);
                            }
                        }
                    }, 1000);
                }
            }
        }
    }

    @Override
    public void onReturnSceneData(Scene scene) {
        Log.e("WWW", " onReturnSceneData==" + new Hashon().fromObject(scene));
        onReturnSceneDataMap = new HashMap<>();
        onReturnSceneDataMap.put("path", scene.getPath());
        onReturnSceneDataMap.put("params", scene.getParams());
    }

    private static void restoreScene() {
        if (mEventSink != null) {
            if (onReturnSceneDataMap != null) {
                mEventSink.success(onReturnSceneDataMap);
                onReturnSceneDataMap = null;
            }
        }
    }
}
