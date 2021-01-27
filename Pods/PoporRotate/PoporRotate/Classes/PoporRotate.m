//
//  PoporRotate.m
//  PoporRotate
//
//  Created by popor on 2020/7/25.
//  Copyright © 2020 popor. All rights reserved.
//

#import "PoporRotate.h"

@implementation PoporRotate

+ (instancetype)share {
    static dispatch_once_t once;
    static PoporRotate * instance;
    dispatch_once(&once, ^{
        instance = [PoporRotate new];
        
        // vc nc
        instance.autorotate        = NO;
        instance.supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
        
        instance.autorotate_moment = NO;
        instance.autorotate_moment_delay = 0.1;
    });
    return instance;
}

- (void)setAutorotate_moment:(BOOL)autorotate_moment {
    if (autorotate_moment) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.autorotate_moment_delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.autorotate_moment = NO;
        });
    }
    _autorotate_moment = autorotate_moment;
}

#pragma mark - VC 部分
- (void)orientationAll {
    self.autorotate = YES;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    } else {
        self.supportedInterfaceOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
    }
    
    self.pMM = [PoporMotionManager new];
    [self.pMM startMonitor:^(PoporMotionManager *poporMotionManager, BOOL success) {
        if (success) {
            UIDeviceOrientation pmmDeviceOrientation = poporMotionManager.deviceOrientation;
            [UIDevice updateOrientation:pmmDeviceOrientation];
        } else {
            [UIDevice updateOrientation:UIDeviceOrientationPortrait];
        }
    }];
}

- (void)orientation_all:(UIInterfaceOrientationMask)allIOMask priority:(UIInterfaceOrientationMask)priorityIOMask high:(UIInterfaceOrientationMask)highIOMask {
    self.autorotate = YES;
    self.supportedInterfaceOrientations = allIOMask;
    
    self.pMM = [PoporMotionManager new];
    [self.pMM startMonitor:^(PoporMotionManager *poporMotionManager, BOOL success) {
        if (success) {
            UIInterfaceOrientationMask pmmIOMask = poporMotionManager.interfaceOrientationMask;
            //NSLog(@"highIOMask: %li - , pmmIOMask: %li", highIOMask, pmmIOMask);
            if (priorityIOMask & pmmIOMask) {
                [UIDevice updateOrientation:[UIDevice deviceOrientation_interfaceOrientationMask:pmmIOMask]];
            } else {
                [UIDevice updateOrientation:[UIDevice deviceOrientation_interfaceOrientationMask:highIOMask]];
            }
        } else {
            [UIDevice updateOrientation:[UIDevice deviceOrientation_interfaceOrientationMask:highIOMask]];
        }
    }];
}

- (void)orientationAll_high:(UIDeviceOrientation)orientation {
    self.autorotate = YES;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    } else {
        self.supportedInterfaceOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
    }
    
    [UIDevice updateOrientation:orientation];
}

- (void)orientationLeft {
    self.autorotate_moment = YES;
    self.autorotate = NO;
    self.supportedInterfaceOrientations = UIInterfaceOrientationMaskLandscapeRight;
    [UIDevice updateOrientation:UIDeviceOrientationLandscapeLeft];
}

- (void)orientationRitht {
    self.autorotate_moment = YES;
    self.autorotate = NO;
    self.supportedInterfaceOrientations = UIInterfaceOrientationMaskLandscapeLeft;
    [UIDevice updateOrientation:UIDeviceOrientationLandscapeRight];
}

- (void)orientationLandscape_priorityLeft:(BOOL)priorityLeft {
    // 这个左右是相反的
    UIDeviceOrientation priorityDeviceOrientation = !priorityLeft ? UIDeviceOrientationLandscapeLeft:UIDeviceOrientationLandscapeRight;
    
    self.autorotate = YES;
    self.supportedInterfaceOrientations = UIInterfaceOrientationMaskLandscape;
    
    self.pMM = [PoporMotionManager new];
    [self.pMM startMonitor:^(PoporMotionManager *poporMotionManager, BOOL success) {
        if (success) {
            UIDeviceOrientation pmmDeviceOrientation = poporMotionManager.deviceOrientation;
            if (pmmDeviceOrientation != UIDeviceOrientationLandscapeLeft
                && pmmDeviceOrientation != UIDeviceOrientationLandscapeRight) {
                [UIDevice updateOrientation:priorityDeviceOrientation];
            } else {
                [UIDevice updateOrientation:pmmDeviceOrientation];
            }
        } else {
            [UIDevice updateOrientation:priorityDeviceOrientation];
        }
    }];
}

- (void)orientationUp {
    self.autorotate_moment = YES;
    self.autorotate = NO;
    self.supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
    [UIDevice updateOrientation:UIDeviceOrientationPortrait];
}

- (void)orientationVertical_priorityUp:(BOOL)priorityUp {
    // 这个左右是相反的
    UIDeviceOrientation priorityDeviceOrientation = priorityUp ? UIDeviceOrientationPortrait:UIDeviceOrientationPortraitUpsideDown;
    
    self.autorotate = YES;
    self.supportedInterfaceOrientations = UIDeviceOrientationPortrait | UIDeviceOrientationPortraitUpsideDown;
    
    self.pMM = [PoporMotionManager new];
    [self.pMM startMonitor:^(PoporMotionManager *poporMotionManager, BOOL success) {
        if (success) {
            UIDeviceOrientation pmmDeviceOrientation = poporMotionManager.deviceOrientation;
            if (pmmDeviceOrientation != UIDeviceOrientationPortrait
                && pmmDeviceOrientation != UIDeviceOrientationPortraitUpsideDown) {
                [UIDevice updateOrientation:priorityDeviceOrientation];
            } else {
                [UIDevice updateOrientation:pmmDeviceOrientation];
            }
        } else {
            [UIDevice updateOrientation:priorityDeviceOrientation];
        }
    }];
    
}


@end
