//
//  ListVCRouter.h
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import <UIKit/UIKit.h>

// 处理View跳转和viper组件初始化
@interface ListVCRouter : NSObject

+ (UIViewController *)vcWithDic:(NSDictionary *)dic;
+ (void)setVCPresent:(UIViewController *)vc;

@end
