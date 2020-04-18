//
//  PoporPopNormalNC.m
//  popor
//
//  Created by popor on 2017/4/25.
//  Copyright © 2017年 popor. All rights reserved.
//

#import "PoporPopNormalNC.h"

#import <PoporUI/UIViewController+pNcBar.h>

@interface PoporPopNormalNC () <UINavigationControllerDelegate>

@end

@implementation PoporPopNormalNC

#pragma mark - 初始化
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    PoporPopNormalNC * nc = [super initWithRootViewController:rootViewController];
    
    return nc;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    PoporPopNormalNC * nc = [super initWithCoder:aDecoder];
    
    return nc;
}

- (instancetype)init {
    PoporPopNormalNC * nc = [super init];
    
    return nc;
}

#pragma mark - 设置
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.translucent = NO;
    self.delegate                  = self;
    
    [self setInteractivePopGRDelegate];
}

- (void)setBarBackImage:(UIImage *)barBackImage{
    self.navigationBar.backIndicatorImage               = barBackImage;
    self.navigationBar.backIndicatorTransitionMaskImage = barBackImage;
}

- (void)setInteractivePopGRDelegate {
    self.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
}

#pragma mark 侧滑判断
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        if (self.viewControllers.count > 1) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return YES;
    }
}

#pragma mark 是否隐藏状态栏
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [navigationController setNavigationBarHidden:viewController.hiddenNcBar animated:YES];
}

#pragma mark 设置返回按钮title
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.isUpdateBarBackTitle) {
        self.topViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.barBackTitle style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    if (self.forbiddenPushSameViewController && [self.topViewController isMemberOfClass:[viewController class]]) {
        // 禁止push相同的vc
        NSLog(@"PoporPopNormalNC: forbidden Push Same ViewController.");
    }else{
        if (self.autoHidesBottomBarWhenPushed) {
            if (self.viewControllers.count > 0) {
                viewController.hidesBottomBarWhenPushed = YES;
            }
        }
        [super pushViewController:viewController animated:animated];
    }
}

@end
