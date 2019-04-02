//
//  SongListDetailVCRouter.h
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.

#import <UIKit/UIKit.h>

// 处理View跳转和viper组件初始化
@interface SongListDetailVCRouter : NSObject

+ (UIViewController *)vcWithDic:(NSDictionary *)dic;
+ (void)setVCPresent:(UIViewController *)vc;

@end
