//
//  MRouterConfig.m
//  hywj
//
//  Created by popor on 2020/5/25.
//  Copyright © 2020 popor. All rights reserved.
//

#import "MRouterConfig.h"
#import <PoporFoundation/NSObject+pSwizzling.h>

NSString * const MRouterScheme = @"lm://";
NSString * const MRouterNC     = @"nc";

@implementation MRouterConfig

+ (void)deregisterURLPattern:(NSString *)URLPattern {
    [MGJRouter deregisterURLPattern:URLPattern];
}

+ (void)registerURL:(NSString *)url toHandel:(MGJRouterHandler)handel {
    if (![url hasPrefix:MRouterScheme]) {
        url = MUrl(url);
    }
    [MGJRouter registerURLPattern:url toHandler:handel];
}

+ (void)pushVC:(UIViewController *)vc dic:(NSDictionary *)dic {
    UINavigationController * nc = dic[MRouterNC];
    if (!nc) {
        nc = [self currentNC];
    }
    
    if (nc) {
        [nc pushViewController:vc animated:YES];
    }
}

+ (NSMutableDictionary *)mixDic:(NSDictionary *)routerParameters {
    NSMutableDictionary * dic = [NSMutableDictionary new];
    [dic addEntriesFromDictionary:routerParameters];
    [dic addEntriesFromDictionary:routerParameters[MGJRouterParameterUserInfo]];
    return dic;
}

// https://www.jianshu.com/p/81057958b64d
+ (UIViewController *)jsd_getRootViewController{
    
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    NSAssert(window, @"The window is empty");
    return window.rootViewController;
}

+ (UINavigationController *)currentNC {
    UIViewController* rootVC = [self jsd_getRootViewController];
    UINavigationController * NC;
    if (rootVC.presentedViewController) {
        // rootVC = rootVC.presentedViewController;
        // present 类型的, 这个需要异常处理
    } else {
        if ([rootVC isKindOfClass:[UITabBarController class]]) {
            NC = ((UITabBarController* )rootVC).selectedViewController;
        }
        else if ([rootVC isKindOfClass:[UINavigationController class]]) {
            NC = (UINavigationController *)rootVC;
        }
    }
    return NC;
}

+ (UIViewController *)jsd_findVisibleViewController {
    
    UIViewController* currentViewController = [self jsd_getRootViewController];
    
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        } else {
            if ([currentViewController isKindOfClass:[UINavigationController class]]) {
                currentViewController = ((UINavigationController *)currentViewController).visibleViewController;
            } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
                currentViewController = ((UITabBarController* )currentViewController).selectedViewController;
            } else {
                break;
            }
        }
    }
    
    return currentViewController;
}

//+ (void)load {
//    static dispatch_once_t once;
//    dispatch_once(&once, ^{
//
//
//    });
//}

// !!!: 工具
+ (void)analysisUrl:(NSString *)urlSting finish:(void (^ __nullable)(NSString * urlPath, NSMutableDictionary * urlQueryDic))finish {
    if (!finish || !urlSting) {
        return;
    }
    NSURL    * tempURL  = [NSURL URLWithString:urlSting];
    NSArray  * urlQueryArray = [[tempURL query] componentsSeparatedByString:@"&"];
    if (urlQueryArray.count == 0) {
        finish(tempURL.path, nil);
    }else{
        NSMutableDictionary *urlQueryDic = [[NSMutableDictionary alloc] init];
        for (NSString *param in urlQueryArray) {
            NSArray *elts = [param componentsSeparatedByString:@"="];
            if([elts count] < 2) {
                continue;
            }else{
                [urlQueryDic setObject:[[elts lastObject] toUtf8Encode] forKey:[elts firstObject]];
            }
        }
        
        finish(tempURL.path, urlQueryDic);
    }
}


@end

@implementation MGJRouter (hywj)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSObject SwizzleClass:objc_getClass("MGJRouter") classMethod:@selector(openURL:withUserInfo:completion:) withMethod:@selector(hywjOpenURL:withUserInfo:completion:)];
    });
}

+ (void)hywjOpenURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo completion:(void (^)(id result))completion {
    if (![URL hasPrefix:MRouterScheme]) {
        URL = MUrl(URL);
    }
    
    [MGJRouter hywjOpenURL:URL withUserInfo:userInfo completion:completion];
}

@end
