//
//  PAutorotate.h
//  hywj
//
//  Created by popor on 2020/7/25.
//  Copyright © 2020 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PAutorotate : NSObject

@property (nonatomic        ) BOOL autorotate;
@property (nonatomic        ) BOOL autorotate_moment;// 打开一段时间后关闭, 默认为0.35秒后关闭
//@property (nonatomic        ) UIInterfaceOrientationMask supportedInterfaceOrientations; // 默认为UIInterfaceOrientationMaskPortrait

@property (nonatomic        ) BOOL appLoaded;

+ (instancetype)share;

@end

NS_ASSUME_NONNULL_END
