//
//  PoporAFN.m
//  PoporAFN
//
//  Created by popor on 17/4/28.
//  Copyright © 2017年 popor. All rights reserved.
//

#import "PoporAFN.h"

//如何添加head.
//https://www.jianshu.com/p/c741236c5c30

@implementation PoporAFN

#pragma mark - NEW
- (void)title:(NSString *_Nullable)title
          url:(NSString *_Nullable)urlString
       method:(PoporMethod)method
   parameters:(NSDictionary *_Nullable)parameters
      success:(PoporAFNFinishBlock _Nullable)success
      failure:(PoporAFNFailureBlock _Nullable)failure
{
    [self title:title url:urlString method:method parameters:parameters afnManager:nil header:nil postData:nil progress:nil success:success failure:failure];
}

- (void)title:(NSString *_Nullable)title
          url:(NSString *_Nullable)urlString
       method:(PoporMethod)method
   parameters:(NSDictionary *_Nullable)parameters
   afnManager:(AFURLSessionManager *_Nullable)manager
       header:(NSDictionary *_Nullable)header
     postData:(nullable void (^)(id <AFMultipartFormData> formData))postDataBlock
     progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
      success:(PoporAFNFinishBlock _Nullable)success
      failure:(PoporAFNFailureBlock _Nullable)failure
{
    if (!manager) {
        manager = [PoporAFNConfig createManager];
    }
    
    if (!header) {
        header = [PoporAFNConfig createHeader];
    }
    __weak typeof(manager) weakManager = manager;
    switch(method) {
        case PoporMethodGet : {
            [(AFHTTPSessionManager *)manager GET:urlString parameters:parameters headers:header progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [PoporAFN successManager:weakManager url:urlString title:title method:method header:header parameters:parameters task:task response:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [PoporAFN failManager:weakManager url:urlString title:title method:method header:header parameters:parameters task:task error:error failure:failure];
            }];
            break;
        }
        case PoporMethodPost : {
            [(AFHTTPSessionManager *)manager POST:urlString parameters:parameters headers:header progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [PoporAFN successManager:weakManager url:urlString title:title method:method header:header parameters:parameters task:task response:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [PoporAFN failManager:weakManager url:urlString title:title method:method header:header parameters:parameters task:task error:error failure:failure];
            }];
            break;
        }
        case PoporMethodFormData: {
           
            [(AFHTTPSessionManager *)manager POST:urlString parameters:parameters headers:header constructingBodyWithBlock:postDataBlock progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [PoporAFN successManager:weakManager url:urlString title:title method:method header:header parameters:parameters task:task response:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [PoporAFN failManager:weakManager url:urlString title:title method:method header:header parameters:parameters task:task error:error failure:failure];
            }];
            
            // // 另一种方法: 抓包发现 这个方法的参数比较简洁
            // NSMutableURLRequest * request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters error:nil];
            // for (NSString * key in header.keyEnumerator) {
            //     [request addValue:header[key] forHTTPHeaderField:key];
            // }
            //
            // __block NSURLSessionUploadTask * uploadTask;
            // uploadTask = [manager uploadTaskWithStreamedRequest:request progress:uploadProgress completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            //     // if (error) {
            //     //     NSLog(@"Error: %@", error);
            //     // } else {
            //     //     NSLog(@"response:%@, responseObject:%@", response, responseObject);
            //     //     NSString * message = responseObject[@"message"];
            //     //     //NSString * str  = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            //     //     NSLog(@"message: %@", message);
            //     // }
            //     if (!error) {
            //         [PoporAFN successManager:weakManager url:urlString title:title method:method parameters:parameters task:uploadTask response:responseObject success:success];
            //     } else {
            //         [PoporAFN failManager:weakManager url:urlString title:title method:method parameters:parameters task:uploadTask error:error failure:failure];
            //     }
            // }];
            //
            // [uploadTask resume];
            
            break;
        }
    }
}



+ (void)successManager:(AFURLSessionManager *)manager url:(NSString *)urlString title:(NSString *_Nullable)title method:(PoporMethod)method header:(NSDictionary *)header parameters:(NSDictionary * _Nullable)parameters task:(NSURLSessionDataTask * _Nullable)task response:(id _Nullable) responseObject success:(PoporAFNFinishBlock _Nullable )success
{
    [manager invalidateSessionCancelingTasks:YES resetSession:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dic = nil;
        if (responseObject) {
            if ([responseObject isKindOfClass:[NSData class]]) {
                dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                if (success) {
                    success(urlString, responseObject, dic);
                }
            } else if ([responseObject isKindOfClass:[NSDictionary class]]) {
                dic = (NSDictionary *)responseObject;
                if (success) {
                    success(urlString, nil, dic);
                }
            }
        }
        
        PoporAfnRecordBlock recordBlock = [PoporAFNConfig share].recordBlock;
        if (recordBlock) {
            id responseID;
            if (dic) {
                responseID = dic;
            }else{
                if ([responseObject isKindOfClass:[NSData class]]) {
                    NSString * str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                    responseID = str ? :nil;
                }
            }
            recordBlock(task.currentRequest.URL.absoluteString, title, method, header, parameters, responseID);
        }
    });
}

+ (void)failManager:(AFURLSessionManager *)manager url:(NSString *)urlString title:(NSString *_Nullable)title method:(PoporMethod)method header:(NSDictionary *)header parameters:(NSDictionary * _Nullable)parameters task:(NSURLSessionDataTask * _Nullable)task error:(NSError *)error failure:(PoporAFNFailureBlock _Nullable)failure
{
    [manager invalidateSessionCancelingTasks:YES resetSession:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (failure) {
            failure(task, error);
        }
        PoporAfnRecordBlock recordBlock = [PoporAFNConfig share].recordBlock;
        if (recordBlock) {
            recordBlock(task.currentRequest.URL.absoluteString, title, method, header, parameters, @{@"异常":error.localizedDescription});
        }
    });
}

#pragma mark - 下载
- (void)downloadUrl:(NSURL * _Nonnull)downloadUrl
        destination:(NSURL * _Nullable)destinationUrl
           progress:(nullable void (^)(float progress, NSProgress * _Nonnull downloadProgress))progressBlock
             finish:(nullable void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))finishBlock
{
    //默认配置
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //AFN3.0+基于封住URLSession的句柄
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    //请求
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadUrl];
    
    //下载Task操作
    self.downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            float progress = (float)downloadProgress.completedUnitCount/(float)downloadProgress.totalUnitCount;
            // 回到主队列刷新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                progressBlock(progress, downloadProgress);
            });
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        if (destinationUrl) {
            return destinationUrl;
        }else{
            NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
            return [NSURL fileURLWithPath:path];
        }
    } completionHandler:finishBlock];
    
    [self.downloadTask resume];
}


@end

//#pragma mark - OLD
//// 使用默认 AFHTTPSessionManager
//- (void)postUrl:(NSString *_Nullable)urlString
//     parameters:(NSDictionary * _Nullable)parameters
//        success:(PoporAFNFinishBlock _Nullable)success
//        failure:(PoporAFNFailureBlock _Nullable)failure
//{
//    [self postUrl:urlString title:nil parameters:parameters afnManager:nil success:success failure:failure];
//}
//
//// 使用自定义 AFHTTPSessionManager,title
//- (void)postUrl:(NSString *_Nullable)urlString
//          title:(NSString *_Nullable)title
//     parameters:(NSDictionary * _Nullable)parameters
//     afnManager:(AFHTTPSessionManager * _Nullable)manager
//        success:(PoporAFNFinishBlock _Nullable )success
//        failure:(PoporAFNFailureBlock _Nullable)failure
//{
//    [self title:title url:urlString method:PoporMethodPost parameters:parameters afnManager:manager success:success failure:failure];
//}
//
//#pragma mark - get
//// 使用默认 AFHTTPSessionManager
//- (void)getUrl:(NSString *_Nullable)urlString
//    parameters:(NSDictionary * _Nullable)parameters
//       success:(PoporAFNFinishBlock _Nullable)success
//       failure:(PoporAFNFailureBlock _Nullable)failure
//{
//    [self getUrl:urlString title:nil parameters:parameters afnManager:nil success:success failure:failure];
//}
//
//// 使用自定义 AFHTTPSessionManager,title
//- (void)getUrl:(NSString *_Nullable)urlString
//         title:(NSString *_Nullable)title
//    parameters:(NSDictionary * _Nullable)parameters
//    afnManager:(AFHTTPSessionManager * _Nullable)manager
//       success:(PoporAFNFinishBlock _Nullable)success
//       failure:(PoporAFNFailureBlock _Nullable)failure
//{
//   [self title:title url:urlString method:PoporMethodGet parameters:parameters afnManager:manager success:success failure:failure];
//}
