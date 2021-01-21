//
//  UIDevice+pOrientation.m
//  hywj
//
//  Created by popor on 2020/12/31.
//  Copyright © 2020 popor. All rights reserved.
//

#import "UIDevice+pOrientation.h"

@implementation UIDevice (pOrientation)

+ (void)updateOrientation:(UIDeviceOrientation)orientation {
    //SEL selector = NSSelectorFromString(@"setOrientation:");
    //if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
    
    SEL selector = @selector(setOrientation:);
    if ([[UIDevice currentDevice] respondsToSelector:selector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = (int)orientation;
        [invocation setArgument:&val atIndex:2];//从2开始，因为0 1 两个参数已经被selector和target占用
        [invocation invoke];
    }
}

@end
