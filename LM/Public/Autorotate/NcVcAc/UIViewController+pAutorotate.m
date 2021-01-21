//
//  UIViewController+pAutorotate.m
//  hywj
//
//  Created by popor on 2020/6/12.
//  Copyright © 2020 popor. All rights reserved.
//

#import "UIViewController+pAutorotate.h"

@implementation UIViewController (pAutorotate)

// 一般有NC的话,不会来这里.
// 默认不旋转 是否可以旋转
- (BOOL)shouldAutorotate {
    PAutorotate * share = [PAutorotate share];
    //NSLog(@"VC class: %@, .autorotate: %i", NSStringFromClass([self class]), share.autorotate);
    
    if (share.autorotate_moment) {
        share.autorotate_moment = NO;
        return YES;
    } else {
        return share.autorotate;
    }
}

+ (CGFloat)portainWidth {
    static CGFloat width;
    if (width == 0) {
        width = MIN(PSCREEN_SIZE.width, PSCREEN_SIZE.height);
    }
    return width;
}

+ (CGFloat)portainHeight {
    static CGFloat height;
    if (height == 0) {
        height = MAX(PSCREEN_SIZE.width, PSCREEN_SIZE.height);
    }
    return height;
}

@end
