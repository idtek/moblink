package com.example.moblinkexample;

import com.example.moblink.MoblinkPlugin;
import com.mob.moblink.MobLink;

import io.flutter.app.FlutterApplication;

public class MoblinkFlutterApplication extends FlutterApplication {

    @Override
    public void onCreate() {
        super.onCreate();
        MobLink.setRestoreSceneListener(new MoblinkPlugin.SceneListener());
    }
}
