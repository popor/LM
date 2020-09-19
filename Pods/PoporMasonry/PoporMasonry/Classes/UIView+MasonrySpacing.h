//
//  UIView+MasonrySpacing.h
//  PoporSegmentView_Example
//
//  Created by apple on 2019/8/12.
//  Copyright © 2019 popor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN

// 代码拷贝自 https://blog.csdn.net/watertekhqx/article/details/72957656 , UIView+Masonry_LJC.h

@interface UIView (MasonrySpacing)

- (void)masSpacingHorizontallyWith:(NSArray *)views;

- (void)masSpacingVerticallyWith:(NSArray *)views;

// -------------------------------------------------------------------------
// 下面是原先作者函数
- (void)distributeSpacingHorizontallyWith:(NSArray *)views;

- (void)distributeSpacingVerticallyWith:(NSArray *)views;

@end

NS_ASSUME_NONNULL_END
