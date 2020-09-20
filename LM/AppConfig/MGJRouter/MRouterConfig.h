//
//  MRouterConfig.h
//  hywj
//
//  Created by popor on 2020/5/25.
//  Copyright © 2020 popor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MGJRouter/MGJRouter.h>
#import "MRouterUrlPrefix.h"

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString * const MRouterScheme;
UIKIT_EXTERN NSString * const MRouterNC;

#define MRouterC MRouterConfig
#define MRCShare [MRouterConfig shareMRouterConfig]

#define MUrl(url) [NSString stringWithFormat:@"%@%@", MRouterScheme, url]
#define MUrlValues(url, value) [NSString stringWithFormat:@"%@%@%@", MRouterScheme, url, value]

@interface MRouterConfig : NSObject

+ (void)deregisterURLPattern:(NSString *)URLPattern;

+ (void)registerURL:(NSString *)url toHandel:(MGJRouterHandler)handel;

+ (void)pushVC:(UIViewController *)vc dic:(NSDictionary *)dic;

+ (NSMutableDictionary *)mixDic:(NSDictionary *)routerParameters;

+ (void)analysisUrl:(NSString *)urlSting finish:(void (^ __nullable)(NSString * urlPath, NSMutableDictionary * urlQueryDic))finish;

@end

@interface MGJRouter (hywj)

@end

NS_ASSUME_NONNULL_END
