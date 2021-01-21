//
//  UINavigationController+pAutorotate.h
//  hywj
//
//  Created by popor on 2020/7/25.
//  Copyright © 2020 popor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PAutorotate.h"

NS_ASSUME_NONNULL_BEGIN

/*
 // UITabBarController 关于子页面的控制方法.
 #pragma mark - 屏幕旋转
 //是否跟随屏幕旋转
 - (BOOL)shouldAutorotate{
 //NSLogInt(self.selectedViewController.shouldAutorotate);
 return self.selectedViewController.shouldAutorotate;
 }
 //支持旋转的方向有哪些
 - (UIInterfaceOrientationMask)supportedInterfaceOrientations{
 return [self.selectedViewController supportedInterfaceOrientations];
 }
 //控制 vc present进来的横竖屏和进入方向 ，支持的旋转方向必须包含改返回值的方向 （详细的说明见下文）
 - (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
 return [self.selectedViewController preferredInterfaceOrientationForPresentation];
 }
 */
@interface UINavigationController (pAutorotate)

@end

NS_ASSUME_NONNULL_END
