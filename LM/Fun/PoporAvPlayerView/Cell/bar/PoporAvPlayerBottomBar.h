//
//  PoporAvPlayerBottomBar.h
//  hywj
//
//  Created by popor on 2020/9/5.
//  Copyright © 2020 popor. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PoporAvPlayerBottomBar;

@protocol PoporAvPlayerBottomBarDelegate <NSObject>

- (BOOL)poporAvPlayerBottomBar:(PoporAvPlayerBottomBar *)poporAvPlayerBottomBar currentTime:(double)currentTime totalTime:(double)totalTime;

@end

@interface PoporAvPlayerBottomBar : UIView

@property (nonatomic, weak  ) id<PoporAvPlayerBottomBarDelegate> delegate;

@property (nonatomic, strong) UIButton       * previousBT;
@property (nonatomic, strong) UIButton       * playButton; // select 是三角, 
@property (nonatomic, strong) UIButton       * playButton_mini;// mini模式下的play按钮, 例如用于悬浮的时候. 默认为hidden
@property (nonatomic, strong) UIButton       * nextBT;

@property (nonatomic, strong) UISlider       * progressSlider;
@property (nonatomic, strong) UIProgressView * bufferProgressView;/// 缓冲进度条

@property (nonatomic, strong) UILabel        * timeElapseL;// 流逝的时间
@property (nonatomic, strong) UILabel        * timeTotalL;// 总时间

@property (nonatomic, strong) UIButton       * rateBT;// 倍速
@property (nonatomic, strong) UIButton       * definitionBT;// 清晰度

@property (nonatomic, strong) UIButton       * videoNumBT;//选集
@property (nonatomic, strong) UIButton       * landscapeButton;


@property (nonatomic        ) BOOL      videoNumBTShowWhenPortait;     // 竖屏的时候是否显示 集数按钮
@property (nonatomic        ) BOOL      definitionBTShowWhenPortait;   // 竖屏的时候是否显示 清晰度按钮

@property (nonatomic        ) BOOL      videoNumBTShowWhenLandscape;   // 横屏的时候是否显示 集数按钮
@property (nonatomic        ) BOOL      definitionBTShowWhenLandscape; // 横屏的时候是否显示 清晰度按钮

- (void)defalutMasonry;

- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime;

- (void)setPlayBTStatus_playing;
- (void)setPlayBTStatus_pause;

- (BOOL)isPlayBTStatus_playing;

@end

NS_ASSUME_NONNULL_END
