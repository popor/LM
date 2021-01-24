//
//  UIViewController+PoporRotate.m
//  PoporRotate
//
//  Created by popor on 2020/6/12.
//  Copyright © 2020 popor. All rights reserved.
//

#import "UIViewController+PoporRotate.h"
#import "PoporRotate.h"

@implementation UIViewController (pAutorotate)

// 一般有NC的话,不会来这里.
// 默认不旋转 是否可以旋转
- (BOOL)shouldAutorotate {
    PoporRotate * share = [PoporRotate share];
    //NSLog(@"VC class: %@, .autorotate: %i", NSStringFromClass([self class]), share.autorotate);
    
    if (share.autorotate_moment) {
        share.autorotate_moment = NO;
        return YES;
    } else {
        return share.autorotate;
    }
}

@end
