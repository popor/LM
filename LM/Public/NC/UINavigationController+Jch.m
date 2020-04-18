//
//  UINavigationController+Jch.m
//  linRunShengPi
//
//  Created by apple on 2018/10/8.
//  Copyright © 2018 艾慧勇. All rights reserved.
//

#import "UINavigationController+Jch.h"

@implementation UINavigationController (Jch)

- (void)setVRSNCBarTitleColor {
    // 设置标题颜色
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [dict setObject:PFONT18 forKey:NSFontAttributeName];
    
    self.navigationBar.titleTextAttributes = dict;
    
    // 设置bar背景颜色
    //[self.navigationBar setBarTintColor:RGB16(0X4077ED)];
    //[self.navigationBar setBarTintColor:ColorNCBar];
    //RGB16(0X68D3FF)
    
    [self.navigationBar setBackgroundImage:[UIImage gradientImageWithBounds:CGRectMake(0, 0, PSCREEN_SIZE.width, 1) andColors:@[PRGB16(0X68D3FF), PRGB16(0X4585F5)] gradientHorizon:YES] forBarMetrics:UIBarMetricsDefault];
    
    
    // 设置返回按钮字体颜色.
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
}

@end
