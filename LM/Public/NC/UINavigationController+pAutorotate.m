//
//  UINavigationController+pAutorotate.m
//  hywj
//
//  Created by popor on 2020/7/25.
//  Copyright © 2020 popor. All rights reserved.
//

#import "UINavigationController+pAutorotate.h"

@implementation UINavigationController (pAutorotate)

// 默认不旋转 是否可以旋转
- (BOOL)shouldAutorotate {
#if TARGET_OS_MACCATALYST
    return NO;
#elif TARGET_OS_IPHONE
    return NO;
#elif TARGET_OS_IPAD
    return YES;
#endif
    return YES;
}

@end
