//
//  PoporMotionManager.m
//  PoporRotate
//
//  Created by popor on 2018/1/20.
//  Copyright © 2018年 popor. All rights reserved.
//

#import "PoporMotionManager.h"
#import "UIDevice+PoporRotate.h"

#import <CoreMotion/CoreMotion.h>

@implementation PoporMotionManager

- (void)startMonitor:(PoporMotionManagerBlock __nullable)finishBolck {
    self.finishBolck = finishBolck;
    if (self.motionManager == nil) {
        self.motionManager = [[CMMotionManager alloc] init];
    }
    // 刷新数据频率
    self.motionManager.deviceMotionUpdateInterval = 1/20.0;
    
    // 判断设备的传感器是否可用
    if (self.motionManager.deviceMotionAvailable) {
        //NSLog(@"PoporMotionManager : Device Motion(陀螺仪) Available");
        __weak typeof(self) weakSelf = self;
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]  withHandler: ^(CMDeviceMotion *motion, NSError*error){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.finishBolck) {
                    weakSelf.finishBolck(weakSelf, YES);
                }
            });
        }];
    } else {
        //NSLog(@"PoporMotionManager : No device motion(陀螺仪) on device.");
        self.motionManager = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.finishBolck) {
                self.finishBolck(self, NO);
            }
        });
    }
}

- (void)stopMonitor {
    [self.motionManager stopDeviceMotionUpdates];
}

- (UIImageOrientation)imageOritation {
    return [UIDevice imageOrientation_deviceOrientation:[self deviceOrientation]];
}

- (UIInterfaceOrientation)interfaceOrientation {
    return [UIDevice interfaceOrientation_deviceOrientation:[self deviceOrientation]];
}

- (UIInterfaceOrientationMask)interfaceOrientationMask {
    return [UIDevice interfaceOrientationMask_deviceOrientation:[self deviceOrientation]];
}

- (UIDeviceOrientation)deviceOrientation {
    return [self handleDeviceMotion:self.motionManager.deviceMotion];
}

- (UIDeviceOrientation)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    //NSLog(@"x:%f, y:%f", x, y);
    
    if (fabs(y) >= fabs(x)) {
        if (y >= 0){
            //NSLog(@"PoporOrientation PoporMotionManager: UIDeviceOrientationPortraitUpsideDown");
            //NSLog(@"下");
            return UIDeviceOrientationPortraitUpsideDown;
        } else{
            //NSLog(@"PoporOrientation PoporMotionManager:UIDeviceOrientationPortrait");
            //NSLog(@"上");
            return UIDeviceOrientationPortrait;
        }
    } else {
        if (x >= 0){
            //NSLog(@"PoporOrientation PoporMotionManager: UIDeviceOrientationLandscapeRight");
            //NSLog(@"右");
            return UIDeviceOrientationLandscapeRight;
        } else{
            //NSLog(@"PoporOrientation PoporMotionManager: UIDeviceOrientationLandscapeLeft");
            //NSLog(@"左");
            return UIDeviceOrientationLandscapeLeft;
        }
    }
}

@end
