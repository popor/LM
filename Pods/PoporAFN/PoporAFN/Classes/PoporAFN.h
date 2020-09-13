//
//  PoporAFN.h
//  PoporAFN
//
//  Created by popor on 17/4/28.
//  Copyright © 2017年 popor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PoporAFNConfig.h"
#import <AFNetworking/AFHTTPSessionManager.h>

NS_ASSUME_NONNULL_BEGIN

#define PoporAFNTool [PoporAFN new]

@interface PoporAFN : NSObject

#pragma mark - NEW
- (void)title:(NSString *_Nullable)title
          url:(NSString *_Nullable)urlString
       method:(PoporMethod)method
   parameters:(NSDictionary *_Nullable)parameters
      success:(PoporAFNFinishBlock _Nullable)success
      failure:(PoporAFNFailureBlock _Nullable)failure;

/**
 
 @param manager : post Json格式为AFHTTPSessionManager, formData为AFHTTPSessionManager
 @param postDataBlock : 示例为 ^(id<AFMultipartFormData>  _Nonnull formData) {
 [formData appendPartWithFileData:imageData name:@"file" fileName:@"1.jpg" mimeType:@"image/jpg"]; // 可以传递图片和视频等
 }
 
 manager 示例:
 . json的manager为
 AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
 manager.requestSerializer =  [AFJSONRequestSerializer serializer];
 manager.responseSerializer = [AFHTTPResponseSerializer serializer];
 manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil]; // 不然不支持www.baidu.com.
 manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
 manager.requestSerializer.timeoutInterval = 10.0f;
 
 formData的manager为
 AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
 // request
 manager.requestSerializer  = [AFHTTPRequestSerializer serializer];
 // response
 manager.responseSerializer = [AFJSONResponseSerializer serializer];
 manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/html", @"text/plain",  @"image/jpeg", @"image/png", @"application/octet-stream", @"multipart/form-data", nil];
 manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
 manager.requestSerializer.timeoutInterval = 10.0f;
 
 */
- (void)title:(NSString *_Nullable)title
          url:(NSString *_Nullable)urlString
       method:(PoporMethod)method
   parameters:(NSDictionary *_Nullable)parameters
   afnManager:(AFURLSessionManager *_Nullable)manager
       header:(NSDictionary *_Nullable)header
     postData:(nullable void (^)(id <AFMultipartFormData> formData))postDataBlock
     progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
      success:(PoporAFNFinishBlock _Nullable)success
      failure:(PoporAFNFailureBlock _Nullable)failure;

#pragma mark - 下载
@property (nonatomic, strong) NSURLSessionDownloadTask * downloadTask;

// PoporAFN 需要持久化,否则无法下载
- (void)downloadUrl:(NSURL * _Nonnull)downloadUrl
        destination:(NSURL * _Nullable)destinationUrl
           progress:(nullable void (^)(float progress, NSProgress * _Nonnull downloadProgress))progressBlock
             finish:(nullable void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))finishBlock;

@end

NS_ASSUME_NONNULL_END


//#pragma mark - OLD
//// 使用默认 AFHTTPSessionManager
//- (void)postUrl:(NSString *_Nullable)urlString
//     parameters:(NSDictionary * _Nullable)parameters
//        success:(PoporAFNFinishBlock _Nullable)success
//        failure:(PoporAFNFailureBlock _Nullable)failure;
//
//// 使用自定义 AFHTTPSessionManager,title
//- (void)postUrl:(NSString *_Nullable)urlString
//          title:(NSString *_Nullable)title
//     parameters:(NSDictionary * _Nullable)parameters
//     afnManager:(AFHTTPSessionManager * _Nullable)manager
//        success:(PoporAFNFinishBlock _Nullable)success
//        failure:(PoporAFNFailureBlock _Nullable)failure;
//
//// 使用默认 AFHTTPSessionManager
//- (void)getUrl:(NSString *_Nullable)urlString
//    parameters:(NSDictionary * _Nullable)parameters
//       success:(PoporAFNFinishBlock _Nullable)success
//       failure:(PoporAFNFailureBlock _Nullable)failure;
//
//// 使用自定义 AFHTTPSessionManager,title
//- (void)getUrl:(NSString *_Nullable)urlString
//         title:(NSString *_Nullable)title
//    parameters:(NSDictionary * _Nullable)parameters
//    afnManager:(AFHTTPSessionManager * _Nullable)manager
//       success:(PoporAFNFinishBlock _Nullable)success
//       failure:(PoporAFNFailureBlock _Nullable)failure;
