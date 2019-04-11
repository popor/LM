//
//  AppDelegate.m
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.
//

#import "AppDelegate.h"

#import "AppNetRecordConfig.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if TARGET_IPHONE_SIMULATOR//模拟器
    NSString * iosInjectionPath = @"/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle";
    if ([[NSFileManager defaultManager] fileExistsAtPath:iosInjectionPath]) {
        [[NSBundle bundleWithPath:iosInjectionPath] load];
    }
#endif
    [AppNetRecordConfig showNetRecord];
    
    return YES;
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
