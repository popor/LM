//
//  NetService.m
//  NetService
//
//  Created by popor on 2020/5/20.
//  Copyright © 2020 popor. All rights reserved.
//

#import "NetService.h"
#import "AFNetworking.h"

//#import "LogoutServer.h"
//#import "AppServerUpdate.h"

//#import "AppVersionCheck.h"

//如何添加head.
//https://www.jianshu.com/p/c741236c5c30


NSInteger  const CodeSuceess           = 200;
NSString * const ErrorMessageKey       = @"message";
NSString * const CodeKey               = @"code";

NSString * const NetStatusNC_Wifi      = @"NetStatusNC_Wifiio";
NSString * const NetStatusNC_4G        = @"NetStatusNC_4G";
NSString * const NetStatusNC_Available = @"NetStatusNC_available";
NSString * const NetStatusNC_Null      = @"NetStatusNC_Null";

static BOOL isLogoutProtect; // 防止自动退出短时间内执行多次

@interface NetService ()

//@property (nonatomic, strong) NSURLSessionDataTask * task;

@end

@implementation NetService


+ (void)setup {
    
    {
        PoporAFNConfig * config = [PoporAFNConfig share];
        //        // 设置manager
        //        // 本APP 不适用, 因为manager类型会变化.
        //        config.afnSMBlock = ^AFHTTPSessionManager *{
        //            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        //            // request
        //            manager.requestSerializer  = [AFHTTPRequestSerializer serializer];
        //            
        //            // response
        //            manager.responseSerializer = [AFJSONResponseSerializer serializer];
        //            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/html", @"text/plain",  @"image/jpeg", @"image/png", @"application/octet-stream", @"multipart/form-data", nil];
        //            
        //            manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //            manager.requestSerializer.timeoutInterval = 10.0f;
        //            
        //            return manager;
        //        };
        
        // 设置head示例
        config.afnHeaderBlock = ^NSDictionary * _Nullable{
            return nil;
            // NSMutableDictionary * dic = [NSMutableDictionary new];
            // [dic setValue:@"1" forKey:@"appType"];
            // [dic setValue:[UIDevice getAppVersion_short] forKey:@"version"];
            //
            // UserTokenEntity * token = ADT.token;
            // if (token.access_token.length > 0) {
            //     // token.token_type ==> @"Bearer" bearer 改为固定 Bearer.
            //     [dic setValue:[NSString stringWithFormat:@"%@ %@", @"Bearer", token.access_token] forKey:@"Authorization"];
            // }
            //
            // return dic;
        };
    }
}

+ (void)title:(NSString *_Nullable)title
          url:(NSString *_Nullable)urlString
       method:(PoporMethod)method
   parameters:(NSDictionary *_Nullable)parameters
      success:(PoporAFNFinishBlock _Nullable)success
      failure:(PoporAFNFailureBlock _Nullable)failure
{
    [self title:title url:urlString method:method parameters:parameters afnManager:nil header:nil postData:nil success:success failure:failure];
}

+ (void)title:(NSString *_Nullable)title
          url:(NSString *_Nullable)urlString
       method:(PoporMethod)method
   parameters:(NSDictionary *_Nullable)parameters
   afnManager:(AFURLSessionManager *_Nullable)manager
       header:(NSDictionary *_Nullable)header
      success:(PoporAFNFinishBlock _Nullable)success
      failure:(PoporAFNFailureBlock _Nullable)failure
{
    [self title:title url:urlString method:method parameters:parameters afnManager:manager header:header postData:nil success:success failure:failure];
}

+ (void)title:(NSString *_Nullable)title
          url:(NSString *_Nullable)urlString
       method:(PoporMethod)method
   parameters:(NSDictionary *_Nullable)parameters
   afnManager:(AFURLSessionManager *_Nullable)manager
       header:(NSDictionary *_Nullable)header
     postData:(nullable void (^)(id <AFMultipartFormData> formData))postDataBlock
      success:(PoporAFNFinishBlock _Nullable)success
      failure:(PoporAFNFailureBlock _Nullable)failure
{
    if (method == PoporMethodFormData) {
        manager = [self formDataManager];
    } else {
        manager = [self jsonManager];
    }
    
    [PoporAFNTool title:title url:urlString method:method parameters:parameters afnManager:manager header:header postData:postDataBlock progress:nil success:^(NSString * _Nonnull url, NSData * _Nullable data, NSDictionary * _Nullable dic) {
        if ([NetService checkTitle:title url:urlString dic:dic]) {
            if (success) {
                success(url, data, dic);
            }
        } else {
            if (failure) {
                failure(nil, nil);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        if (failure) {
            if (error) { // 提醒网路异常放到公共函数里面
                // NSString * info = [NSString stringWithFormat:@"%@: %@", title, error.localizedDescription];
                // AlertToastTitle(info);
                
                AlertToastTitle(error.localizedDescription);
            }
            
            // 继续之前的事件
            failure(task, error);
        }
    }];
    
}

+ (AFURLSessionManager *)formDataManager {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // request
    manager.requestSerializer  = [AFHTTPRequestSerializer serializer];
    
    // response
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/html", @"text/plain",  @"image/jpeg", @"image/png", @"application/octet-stream", @"multipart/form-data", nil];
    
    manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    manager.requestSerializer.timeoutInterval = 10.0f;
    return manager;
}

+ (AFURLSessionManager *)jsonManager {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer =  [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"text/plain", nil]; // 不然不支持www.baidu.com.
    
    manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    manager.requestSerializer.timeoutInterval = 10.0f;
    
    return manager;
}

// 系统更新的和被踢下线的,返回NO.
+ (BOOL)checkTitle:(NSString *)title url:(NSString *_Nullable)urlString dic:(NSDictionary *)dic {
    return YES;
}

+ (void)startNetStatusMonitor {
    AFNetworkReachabilityManager * afnSM = [AFNetworkReachabilityManager sharedManager];
    
    [afnSM startMonitoring];
    [afnSM setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                [[NSNotificationCenter defaultCenter] postNotificationName:NetStatusNC_Available object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:NetStatusNC_4G object:nil];
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                [[NSNotificationCenter defaultCenter] postNotificationName:NetStatusNC_Available object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:NetStatusNC_Wifi object:nil];
                break;
            }
            case AFNetworkReachabilityStatusNotReachable: {
                [[NSNotificationCenter defaultCenter] postNotificationName:NetStatusNC_Null object:nil];
                break;
            }
            case AFNetworkReachabilityStatusUnknown: {
                [[NSNotificationCenter defaultCenter] postNotificationName:NetStatusNC_Null object:nil];
                break;
            }
            default: {
                break;
            }
        }
    }];
}

@end
