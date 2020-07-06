#import "MoblinkPlugin.h"

#import <MobLinkPro/MobLink.h>

#import <MobLinkPro/MLSDKScene.h>
#import <MOBFoundation/MOBFoundation.h>
#import <MobLinkPro/IMLSDKRestoreDelegate.h>
#import <MOBFoundation/MobSDK+Privacy.h>
typedef NS_ENUM(NSUInteger, MLSDKPluginMethod) {
    MLSDKPluginMethodGetMobId,
    MLSDKPluginMethodRestoreScene,
    MLSDKPluginMethodUploadPrivacyPermissionStatus,
    MLSDKPluginMethodSetAllowShowPrivacyWindow,
    MLSDKPluginMethodGetPrivacyPolicy,
    MLSDKPluginMethodSetPrivacyUI
};


@interface MoblinkPlugin() <IMLSDKRestoreDelegate,FlutterStreamHandler>

@property (strong, nonatomic) NSDictionary *methodMap;

@property (strong, nonatomic) FlutterEventChannel* channel;

@property (nonatomic, copy) FlutterEventSink  eventSink;


@end
static NSString *const receiverStr = @"MOBLINK_TO_FLUTTER";
@implementation MoblinkPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar
{
    FlutterMethodChannel *channel = [FlutterMethodChannel
                                     methodChannelWithName:@"com.yoozoo.mob/moblink"
                                     binaryMessenger:[registrar messenger]];
    MoblinkPlugin *instance = [[MoblinkPlugin alloc] init];
    
    instance.methodMap = @{
        @"getMobId" : @(MLSDKPluginMethodGetMobId),
        @"restoreScene" : @(MLSDKPluginMethodRestoreScene),
        @"getPrivacyPolicy":@(MLSDKPluginMethodGetPrivacyPolicy),
        @"uploadPrivacyPermissionStatus":@(MLSDKPluginMethodUploadPrivacyPermissionStatus),
        @"setPrivacyUI":@(MLSDKPluginMethodSetPrivacyUI),
        @"setAllowShowPrivacyWindow":@(MLSDKPluginMethodSetAllowShowPrivacyWindow),
    };
    [registrar addMethodCallDelegate:instance channel:channel];
    FlutterEventChannel* e_channel = [FlutterEventChannel eventChannelWithName:receiverStr binaryMessenger:[registrar messenger]];
    [e_channel setStreamHandler:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result
{
    NSNumber *methodType = self.methodMap[call.method];
    
    if (methodType)
    {
        switch (methodType.intValue)
        {
            case MLSDKPluginMethodGetMobId:
            {
                [self _getMobIdWithArgs:call.arguments result:result];
                break;
            }
            case MLSDKPluginMethodRestoreScene:
            {
                [self _restoreScene:result];
                break;
            }
            case MLSDKPluginMethodGetPrivacyPolicy:{
                [self _getPrivacyPolicy:call.arguments result:result];
            }
                break;
            case MLSDKPluginMethodSetAllowShowPrivacyWindow:{
                [self _setAllowShowPrivacyWindow:call.arguments result:result];
            }
                break;
            case MLSDKPluginMethodSetPrivacyUI:{
                [self _setPrivacyUI:call.arguments result:result];
            }
                break;
            case MLSDKPluginMethodUploadPrivacyPermissionStatus:{
                [self _uploadPrivacyPermissionStatus:call.arguments result:result];
            }
                break;
            default:
            {
                NSAssert(NO, @"The method requires an implementation ！");
                break;
            }
        }
    }
    else
    {
        result(FlutterMethodNotImplemented);
    }
}

// 获取mobid
- (void)_getMobIdWithArgs:(NSDictionary *)args result:(FlutterResult)result
{
    MLSDKScene *scene = [MLSDKScene sceneForPath:args[@"path"] params:args[@"params"]];
    
    [MobLink getMobId:scene result:^(NSString *mobid, NSString *domain, NSError *error) {
        
        if (mobid)
        {
            NSDictionary *dic = @{
                @"mobid" : mobid,
                @"domain" : domain?:[NSNull null]
            };
            result(dic);
        }
        if (error)
        {
            NSDictionary *dic = @{
                @"error" : [self _covertError:error]
            };
            result(dic);
        }
    }];
}
- (void)_uploadPrivacyPermissionStatus:(NSDictionary *)args result:(FlutterResult)result{
    [MobSDK uploadPrivacyPermissionStatus:[args[@"status"]boolValue] onResult:^(BOOL success) {
        result(@{@"success":@(success)});
    }];
}

- (void)_setAllowShowPrivacyWindow:(NSDictionary *)args result:(FlutterResult)result{

}

- (void)_getPrivacyPolicy:(NSDictionary *)args result:(FlutterResult)result{
    [MobSDK getPrivacyPolicy:args[@"type"] language:args[@"language"] compeletion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
        result(@{
            @"data":@{@"data":(data[@"content"]?:[NSNull null])},
            @"error":error?@{@"error":@"获取失败"}:[NSNull null]
               });
    }];
}

- (void)_setPrivacyUI:(NSDictionary *)args result:(FlutterResult)result{

}
// 监听还原
- (void)_restoreScene:(FlutterResult)result
{
    [MobLink setDelegate:self];
}

- (id)_covertError:(NSError *)error
{
    if (error)
    {
        return @{@"code":@(error.code),@"userInfo":error.userInfo?:@{}};
    }
    
    return [NSNull null];
}


- (void)IMLSDKWillRestoreScene:(MLSDKScene *)scene Restore:(void (^)(BOOL, RestoreStyle))restoreHandler
{
    if (_eventSink) {
        NSString *path = scene.path;
        NSString *mobid = scene.mobid;
        NSString *rawURL = scene.rawURL;
        NSString *className = scene.className;
        NSDictionary *params = scene.params;
        NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
        if (path)
        {
            [mDic addEntriesFromDictionary:@{@"path" : path}];
        }
        if (mobid)
        {
            [mDic addEntriesFromDictionary:@{@"mobid" : mobid}];
        }
        if (rawURL)
        {
            [mDic addEntriesFromDictionary:@{@"rawURL" : rawURL}];
        }
        if (className)
        {
            [mDic addEntriesFromDictionary:@{@"className" : className}];
        }
        if (params)
        {
            [mDic addEntriesFromDictionary:@{@"params" : params}];
        }
        self.eventSink(mDic);
    }
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
    self.eventSink = events;
    return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments{
    self.eventSink = nil;
    return nil;
}


@end
