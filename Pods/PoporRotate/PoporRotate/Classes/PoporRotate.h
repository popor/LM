//
//  PoporRotate.h
//  PoporRotate
//
//  Created by popor on 2020/7/25.
//  Copyright © 2020 popor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PoporMotionManager.h"
#import "UIDevice+PoporRotate.h"

NS_ASSUME_NONNULL_BEGIN
/**
 用法可以参考 README.md
 */

@interface PoporRotate : NSObject

@property (nonatomic        ) BOOL appLoaded;

// vc 和 nc
@property (nonatomic        ) BOOL autorotate;
@property (nonatomic        ) UIInterfaceOrientationMask supportedInterfaceOrientations; // 默认为UIInterfaceOrientationMaskPortrait

@property (nonatomic        ) BOOL autorotate_moment;// 打开一段时间后关闭, 默认为0.1秒后关闭
@property (nonatomic        ) CGFloat autorotate_moment_delay;// 默认为0.1秒后关闭

// pMM
@property (nonatomic, strong) PoporMotionManager * pMM;

+ (instancetype)share;

#pragma mark - VC 部分
- (void)orientationAll;  // iPhone只有上左右, iPad有上下左右.

- (void)orientationAll_high:(UIDeviceOrientation)orientation;

/**
 *  @brief 允许屏幕全部方向, 但是优先选择某个方向组合(priorityIOMask), 假如没有匹配则使用highIOMask
 *  @param allIOMask 允许旋转的全部方向.
 *  @param priorityIOMask 优先旋转的方向, 包含于allIOMask. 可以为UIInterfaceOrientationMaskPortrait, 也可以是:UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight. 注意不是UIDeviceOrientation类型;
 *  注意UIInterfaceOrientation 和 UIInterfaceOrientationMask 相对于UIDeviceOrientation的左右是相反的.
 *  
 *  @param highIOMask 包含于priorityOrientation
 *
 */
- (void)orientation_all:(UIInterfaceOrientationMask)allIOMask priority:(UIInterfaceOrientationMask)priorityIOMask high:(UIInterfaceOrientationMask)highIOMask;

- (void)orientationLeft; // 针对于iPhone或者iPad.
- (void)orientationRitht;// 针对于iPhone或者iPad.

- (void)orientationLandscape_priorityLeft:(BOOL)priorityLeft;// 针对于iPhone或者iPad.

- (void)orientationUp;   // 一般只针对iPhone.

- (void)orientationVertical_priorityUp:(BOOL)priorityUp;// 针对于iPad.


@end

NS_ASSUME_NONNULL_END
