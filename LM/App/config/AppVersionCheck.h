//
//  AppVersionCheck.h
//  LM
//
//  Created by apple on 2019/4/9.
//  Copyright © 2019 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppVersionEntity : NSObject

@property (nonatomic, strong) NSString * version;
@property (nonatomic, strong) NSString * downloadUrl;

@end

@interface AppVersionCheck : NSObject

// 弹出警告框
+ (void)oneAlertCheckVersionAtVC:(UIViewController *)vc finish:(BlockPBool _Nonnull)finish;

// 每天只自动弹出一次警告框
+ (void)autoAlertCheckVersionAtVc:(UIViewController *)vc finish:(BlockPBool _Nonnull)finish;

@end

NS_ASSUME_NONNULL_END
