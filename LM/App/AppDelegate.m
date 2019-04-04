//
//  AppDelegate.m
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.
//

#import "AppDelegate.h"

//#import "MusicPlayBar.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if TARGET_IPHONE_SIMULATOR//模拟器
    NSString * iosInjectionPath = @"/Applications/InjectionIII.app/Contents/Resources/iOSInjection10.bundle";
    if ([[NSFileManager defaultManager] fileExistsAtPath:iosInjectionPath]) {
        [[NSBundle bundleWithPath:iosInjectionPath] load];
    }
#endif
   

    return YES;
}

//// 启动类型的枚举变量
//typedef NS_ENUM(NSUInteger, STARTUP_TPYE){
//    STARTUP_TPYE_BY_NOMAL = 0,
//    STARTUP_TPYE_BY_NOTIFICATION,
//    STARTUP_TPYE_BY_PUSH,
//    STARTUP_TPYE_BY_SCHEME,
//};
//
//- (STARTUP_TPYE)checkStartUpType:(NSDictionary *)launchOptions{
//    STARTUP_TPYE startType = STARTUP_TPYE_BY_NOMAL;
//    if (launchOptions) {
//        // 有远程通知
//        NSDictionary *payload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//        if (payload) {
//            startType = STARTUP_TPYE_BY_PUSH;
//
//        }
//        // 有本地通知
//        UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
//        if (localNotification) {
//            startType = STARTUP_TPYE_BY_NOTIFICATION;
//
//        }
//        // 有第三方APP调用
//        NSURL* launchURL = (NSURL*)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
//        if(launchURL) {
//            startType = STARTUP_TPYE_BY_SCHEME;
//
//        }
//
//    } else {
//        startType = STARTUP_TPYE_BY_NOMAL;
//
//    }
//    NSString * info = launchOptions.description ? :@"空";
//    AlertToastTitleTime(info, 600);
//    return startType;
//}


// ios 9.1 以前的方案
//    // 接受系统锁屏控制
//    [self becomeFirstResponder];
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//

//- (BOOL)becomeFirstResponder{
//    return YES;
//}
//
//- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
//    switch (event.subtype) {
//        case UIEventSubtypeRemoteControlPlay:
//            [MpbShare playEvent];
//            break;
//        case UIEventSubtypeRemoteControlPause:
//            [MpbShare pauseEvent];
//            break;
//        case UIEventSubtypeRemoteControlStop:
//
//            break;
//
//        case UIEventSubtypeRemoteControlNextTrack: {
//            [MpbShare nextBTEvent];
//            break;
//        }
//        case UIEventSubtypeRemoteControlPreviousTrack: {
//            [MpbShare previousBTEvent];
//            break;
//        }
//        default:
//            break;
//    }
//}

@end
