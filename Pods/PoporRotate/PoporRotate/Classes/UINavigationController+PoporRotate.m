//
//  UINavigationController+pAutorotate.m
//  PoporRotate
//
//  Created by popor on 2020/7/25.
//  Copyright © 2020 popor. All rights reserved.
//

#import "UINavigationController+PoporRotate.h"

#import "PoporRotate.h"

@implementation UINavigationController (PoporRotate)

// 默认不旋转 是否可以旋转
- (BOOL)shouldAutorotate {
    PoporRotate * share = [PoporRotate share];
    //UIViewController * vc = self.topViewController;
    //NSLog(@"NC class: %@, vc:%@, autorotate_moment:%i, .autorotate: %i", NSStringFromClass([self class]), NSStringFromClass([vc class]), share.vcAutorotate_moment, share.vcAutorotate);
    
    if (share.autorotate_moment) {
        share.autorotate_moment = NO;
        return YES;
    } else {
        return share.autorotate;
    }
}

@end
