//
//  AppDelegate.m
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.
//

#import "AppDelegate.h"

#import "AppNetRecordConfig.h"
#import <PoporRotate/PoporRotate.h>

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

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
#if TARGET_OS_MACCATALYST
    return UIInterfaceOrientationMaskPortrait;
#else
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        PoporRotate * pr = [PoporRotate share];
        if (pr.appLoaded) {
            return pr.supportedInterfaceOrientations;
        } else {
            return UIInterfaceOrientationMaskPortrait;
        }
    }
#endif
}

@end
