//
//  NetService.h
//  NetService
//
//  Created by popor on 2020/5/20.
//  Copyright © 2020 popor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PoporAFN/PoporAFN.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSInteger  const CodeSuceess;
UIKIT_EXTERN NSString * const ErrorMessageKey;
UIKIT_EXTERN NSString * const CodeKey;

UIKIT_EXTERN NSString * const NetStatusNC_Wifi;
UIKIT_EXTERN NSString * const NetStatusNC_4G;
UIKIT_EXTERN NSString * const NetStatusNC_Available;
UIKIT_EXTERN NSString * const NetStatusNC_Null;


#ifndef __OPTIMIZE__ //测试
#define NetURL(appendURL) [NSString stringWithFormat:@"%@/%@", [[PoporDomainConfigCustom share] domain], appendURL]

#else //正式
#define NetURL(appendURL) [NSString stringWithFormat:@"%@/%@", DomainRelease, appendURL]

#endif



@class AFHTTPSessionManager;

@interface NetService : NSObject

+ (void)setup;

+ (void)title:(NSString *_Nullable)title
          url:(NSString *_Nullable)urlString
       method:(PoporMethod)method
   parameters:(NSDictionary *_Nullable)parameters
      success:(PoporAFNFinishBlock _Nullable)success
      failure:(PoporAFNFailureBlock _Nullable)failure;

+ (void)title:(NSString *_Nullable)title
          url:(NSString *_Nullable)urlString
       method:(PoporMethod)method
   parameters:(NSDictionary *_Nullable)parameters
   afnManager:(AFURLSessionManager *_Nullable)manager
       header:(NSDictionary *_Nullable)header
      success:(PoporAFNFinishBlock _Nullable)success
      failure:(PoporAFNFailureBlock _Nullable)failure;

+ (void)title:(NSString *_Nullable)title
          url:(NSString *_Nullable)urlString
       method:(PoporMethod)method
   parameters:(NSDictionary *_Nullable)parameters
   afnManager:(AFURLSessionManager *_Nullable)manager
       header:(NSDictionary *_Nullable)header
     postData:(nullable void (^)(id <AFMultipartFormData> formData))postDataBlock
      success:(PoporAFNFinishBlock _Nullable)success
      failure:(PoporAFNFailureBlock _Nullable)failure;

+ (void)startNetStatusMonitor;

+ (AFURLSessionManager *)formDataManager;

+ (AFURLSessionManager *)jsonManager;

@end

NS_ASSUME_NONNULL_END
