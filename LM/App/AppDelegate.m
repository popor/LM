//
//  AppDelegate.m
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.
//

#import "AppDelegate.h"

#import "AppNetRecordConfig.h"

void UncaughtExceptionHandler(NSException *exception) {
    
    [MGJRouter openURL:MUrl_savePlayDepartment];
    [MGJRouter openURL:MUrl_savePlayConfig];
}

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 抓捕异常崩溃信息.
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
    
#if TARGET_IPHONE_SIMULATOR//模拟器
    NSString * iosInjectionPath = @"/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle";
    if ([[NSFileManager defaultManager] fileExistsAtPath:iosInjectionPath]) {
        [[NSBundle bundleWithPath:iosInjectionPath] load];
    }
#endif
    [AppNetRecordConfig showNetRecord];
    
    
#if TARGET_OS_MACCATALYST
    // mac 的 Windows尺寸可以变得小点
    self.window.canResizeToFitContent = YES;
    
    
#else
    
#endif
    
    return YES;
}

//- (void)applicationDidEnterBackground:(UIApplication *)application {
//    [MGJRouter openURL:MUrl_savePlayDepartment];
//}

- (void)applicationWillTerminate:(UIApplication *)application {
    [MGJRouter openURL:MUrl_savePlayDepartment];
    [MGJRouter openURL:MUrl_savePlayConfig];
}

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
