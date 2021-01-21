//
//  VideoConfigTvView.h
//  hywj
//
//  Created by popor on 2020/6/15.
//  Copyright © 2020 popor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoConfigTvView;

NS_ASSUME_NONNULL_BEGIN


@protocol VideoConfigTvViewDelegate <NSObject>

@optional

// 按钮被点击
- (void)videoConfigTvView:(VideoConfigTvView *)configView selectIndex:(NSInteger)indexRow;

// 默认只有一个 section
- (NSInteger)videoConfigTvViewCount:(VideoConfigTvView *)configView;

- (void)videoConfigTvView:(VideoConfigTvView *)configView indexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell;

@end


@interface VideoConfigTvView : UIView

/// delegate
@property (nonatomic, weak) id<VideoConfigTvViewDelegate> delegate;

@property (nonatomic, strong) UITableView * infoTV;
@property (nonatomic, copy  ) NSArray * infoArray; // 要么设置 delegate

@property (nonatomic        ) CGFloat   cellH; //默认为50
@property (nonatomic, copy  ) NSString * selectString;

//@property (nonatomic        ) NSInteger tag;// 额外参数, 仅供外部使用, sdk不适用
@property (nonatomic, weak  ) NSArray * weakEntityArray; // 额外参数, 仅供外部使用, sdk不适用

- (void)showAtView:(UIView *)view;

- (void)showAtView:(UIView *)view tvWidth:(CGFloat)tvWidth;

@end

NS_ASSUME_NONNULL_END
