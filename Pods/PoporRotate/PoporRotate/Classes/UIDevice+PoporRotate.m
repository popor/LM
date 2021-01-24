//
//  UIDevice+PoporRotate.m
//  PoporRotate
//
//  Created by popor on 2020/12/31.
//  Copyright © 2020 popor. All rights reserved.
//

#import "UIDevice+PoporRotate.h"

@implementation UIDevice (PoporRotate)

+ (void)updateOrientation:(UIDeviceOrientation)orientation {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateOrientation_3:orientation];
    });
}

+ (void)updateOrientation_3:(UIDeviceOrientation)orientation{
    //NSLog(@"设备方向 : %li", orientation);
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    
    [self performSelector:@selector(updateOrientation_onceNumber:) withObject:@(orientation) afterDelay:0.0];
    [self performSelector:@selector(updateOrientation_onceNumber:) withObject:@(orientation) afterDelay:0.1];
    [self performSelector:@selector(updateOrientation_onceNumber:) withObject:@(orientation) afterDelay:0.2];
}

+ (void)updateOrientation_5:(UIDeviceOrientation)orientation{
    //NSLog(@"设备方向 : %li", orientation);
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    
    [self performSelector:@selector(updateOrientation_onceNumber:) withObject:@(orientation) afterDelay:0.0];
    [self performSelector:@selector(updateOrientation_onceNumber:) withObject:@(orientation) afterDelay:0.1];
    [self performSelector:@selector(updateOrientation_onceNumber:) withObject:@(orientation) afterDelay:0.2];
    [self performSelector:@selector(updateOrientation_onceNumber:) withObject:@(orientation) afterDelay:0.3];
    [self performSelector:@selector(updateOrientation_onceNumber:) withObject:@(orientation) afterDelay:0.4];
}

+ (void)updateOrientation_onceNumber:(NSNumber *)orientationNumber {
    [self updateOrientation_once:orientationNumber.integerValue];
}

+ (void)updateOrientation_once:(UIDeviceOrientation)orientation {
    //SEL selector = NSSelectorFromString(@"setOrientation:");
    //if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
    //NSLog(@"设备方向 once : %li", orientation);
    
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

+ (UIInterfaceOrientation)interfaceOrientation_deviceOrientation:(UIDeviceOrientation)deviceOrientation {
    UIInterfaceOrientation io;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:{
            io = UIInterfaceOrientationPortrait;
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown:{
            if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
                io = UIInterfaceOrientationPortraitUpsideDown;
            }else{
                // iphone 不允许出现该模式,会崩溃.
                io = UIInterfaceOrientationUnknown;
            }
            break;
        }
        case UIDeviceOrientationLandscapeLeft:{
            io = UIInterfaceOrientationLandscapeRight;
            break;
        }
        case UIDeviceOrientationLandscapeRight:{
            
            io = UIInterfaceOrientationLandscapeLeft;
            break;
        }
        default:{
            io = UIInterfaceOrientationUnknown;
            break;
        }
    }
    return io;
}

+ (UIInterfaceOrientationMask)interfaceOrientationMask_deviceOrientation:(UIDeviceOrientation)deviceOrientation {
    UIInterfaceOrientationMask iom;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:{
            iom = UIInterfaceOrientationMaskPortrait;
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown:{
            if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
                iom = UIInterfaceOrientationMaskPortraitUpsideDown;
            }else{
                //iphone 不允许出现该模式,会崩溃.
                iom = UIInterfaceOrientationMaskAllButUpsideDown;
            }
            break;
        }
        case UIDeviceOrientationLandscapeLeft:{
            iom = UIInterfaceOrientationMaskLandscapeRight;
            break;
        }
        case UIDeviceOrientationLandscapeRight:{
            iom = UIInterfaceOrientationMaskLandscapeLeft;
            break;
        }
        default:{
            iom = UIInterfaceOrientationMaskPortrait;
            break;
        }
    }
    return iom;
}

+ (UIDeviceOrientation)deviceOrientation_interfaceOrientationMask:(UIInterfaceOrientationMask)ioMask {
    UIDeviceOrientation deviceOrientation;
    if (ioMask & UIInterfaceOrientationMaskPortrait) {
        deviceOrientation = UIDeviceOrientationPortrait;
    } else if (ioMask & UIInterfaceOrientationMaskLandscapeLeft) {
        deviceOrientation = UIDeviceOrientationLandscapeRight;
    } else if (ioMask & UIInterfaceOrientationMaskLandscapeRight) {
        deviceOrientation = UIDeviceOrientationLandscapeLeft;
    } else if (ioMask & UIInterfaceOrientationMaskPortraitUpsideDown) {
        deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
    } else {
        deviceOrientation = UIDeviceOrientationPortrait;
    }
    
    return deviceOrientation;
}

+ (UIImageOrientation)imageOrientation_deviceOrientation:(UIDeviceOrientation)deviceOrientation {
    UIImageOrientation imageOritation;
    switch (deviceOrientation) {
            
        case UIDeviceOrientationLandscapeLeft:
            imageOritation = UIImageOrientationUp;
            break;
        case UIDeviceOrientationLandscapeRight:
            imageOritation = UIImageOrientationDown;
            break;
            
            // 这几个都处理成默认
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            imageOritation = UIImageOrientationRight;
            break;
        default:
            imageOritation = UIImageOrientationRight;
            break;
    }
    return imageOritation;
}


@end
