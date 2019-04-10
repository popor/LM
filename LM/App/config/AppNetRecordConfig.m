//
//  AppNetRecordConfig.m
//  linRunShengPi
//
//  Created by apple on 2018/12/21.
//  Copyright © 2018 艾慧勇. All rights reserved.
//

#import "AppNetRecordConfig.h"

#import <PoporNetRecord/PoporNetRecord.h>
#import <AFNetworking/AFHTTPSessionManager.h>

#import "UINavigationController+Jch.h"

@implementation AppNetRecordConfig

+ (void)showNetRecord {
    //NSString * uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    //fprintf(stderr, "uuid : %s\n", [uuid UTF8String]);
    PnrConfig * config =[PnrConfig share];
    BOOL isRecord = NO;
    config.recordType = PoporNetRecordDisable;
    //    if (IsDebugVersion) {
    //        isRecord = YES;
    //        config.recordType = PoporNetRecordAuto;
    //    }else{
    //
    //    }
    if (isRecord) {
        NSString * title;
        NSString * path;
        title = @"LM";
        path = [[NSBundle mainBundle] pathForResource:@"favicon" ofType:@"ico"];
        
        config.webRootTitle = title;
        config.webIconData = [[NSData alloc] initWithContentsOfFile:path];
        // 设置pnr nc样式
        config.presentNCBlock = ^(UINavigationController *nc) {
            [nc setVRSNCBarTitleColor];
        };
        //[self setPnrResubmit];
    }
}

//+ (void)setPnrResubmit {
//    [PoporNetRecord setPnrBlockResubmit:^(NSDictionary *formDic, PnrBlockFeedback  _Nonnull blockFeedback) {
//        NSString * title        = formDic[@"title"];
//        NSString * urlStr       = formDic[@"url"];
//        NSString * methodStr    = formDic[@"method"];
//        NSString * headStr      = formDic[@"head"];
//        NSString * parameterStr = formDic[@"parameter"];
//        //NSString * extraStr     = formDic[@"extra"];
//        title = [title hasPrefix:@"["] ? title:[NSString stringWithFormat:@"[%@]", title];
//
//        AFHTTPSessionManager * manager = [self managerDic:headStr.toDic];
//
//        if ([methodStr.lowercaseString isEqualToString:@"get"]) {
//            [NetService getUrl:urlStr title:title afnManager:manager parameters:parameterStr.toDic success:nil failure:nil];
//        }else if ([methodStr.lowercaseString isEqualToString:@"post"]) {
//            [NetService getUrl:urlStr title:title afnManager:manager parameters:parameterStr.toDic success:nil failure:nil];
//        }
//    } extraDic:nil];
//}

+ (AFHTTPSessionManager *)managerDic:(NSDictionary *)dic {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer =  [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil]; // 不然不支持www.baidu.com.
    
    NSArray * keyArray = dic.allKeys;
    for (NSString * key in keyArray) {
        [manager.requestSerializer setValue:dic[key] forHTTPHeaderField:key];
    }
    
    manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    manager.requestSerializer.timeoutInterval = 10.0f;
    
    return manager;
}


@end
