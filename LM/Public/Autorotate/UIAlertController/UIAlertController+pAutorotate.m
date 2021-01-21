//
//  UIAlertController+pAutorotate.m
//  PoporUI
//
//  Created by popor on 2020/11/28.
//

#import "UIAlertController+pAutorotate.h"

@implementation UIAlertController (pAutorotate)

- (BOOL)shouldAutorotate {
    //return NO;
    //NSLog(@"%s autorotate : %i", __func__, [UIAcPautorotate share].rotateEnable);
    return [UIAcPautorotate share].rotateEnable;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    //return UIInterfaceOrientationMaskPortrait;
    return [UIAcPautorotate share].supportedInterfaceOrientations;
}

@end


@implementation UIAcPautorotate

+ (instancetype)share {
    static dispatch_once_t once;
    static UIAcPautorotate * instance;
    dispatch_once(&once, ^{
        instance = [self new];
        instance.rotateEnable = NO;
        instance.supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
    });
    return instance;
}

@end
