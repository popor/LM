//
//  PoporMotionManager.h
//  PoporRotate
//
//  Created by popor on 2018/1/20.
//  Copyright © 2018年 popor. All rights reserved.
//
//  作者：维多的忧伤
//  链接：
//  來源：简书
//  简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。
//  
//  https://www.jianshu.com/p/56d22b395e44

#import <Foundation/Foundation.h>

@class PoporMotionManager;
@class CMMotionManager;

typedef void(^PoporMotionManagerBlock)(PoporMotionManager * __nullable poporMotionManager, BOOL success); // __BlockTypedef

@interface PoporMotionManager : NSObject

@property (nonatomic, strong) CMMotionManager * _Nullable motionManager;
@property (nonatomic, copy  ) PoporMotionManagerBlock _Nullable finishBolck;

- (void)startMonitor:(PoporMotionManagerBlock __nullable)finishBolck;
- (void)stopMonitor;

- (UIImageOrientation)imageOritation;
- (UIDeviceOrientation)deviceOrientation;
- (UIInterfaceOrientation)interfaceOrientation;
- (UIInterfaceOrientationMask)interfaceOrientationMask;

@end
