//
//  PoporAvPlayerViewProtocol.h
//  hywj
//
//  Created by popor on 2020/9/5.
//  Copyright © 2020 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PoporAVPlayerPrifix.h"
#import "PoporAVPlayerLayer.h"
#import "PoporAvPlayerRecord.h"

#import "PoporAvPlayerTopBar.h"
#import "PoporAvPlayerBottomBar.h"
#import "PoporAvPanGR.h"

@class PoporAvPlayerView;

NS_ASSUME_NONNULL_BEGIN

typedef void(^PoporAvPlayerBlock_layoutTopBar)        (PoporAvPlayerTopBar * topBar);

typedef void(^PoporAvPlayerBlock_layoutBottomBar)     (PoporAvPlayerBottomBar * bottomBar);
typedef void(^PoporAvPlayerBlock_layoutBottomBarTime) (PoporAvPlayerBottomBar * bottomBar, double currentTime, double totalTime);

typedef void(^PoporAvPlayerBlock_layoutTopBottomBar)  (PoporAvPlayerTopBar * topBar, PoporAvPlayerBottomBar * bottomBar);

@protocol PoporAvPlayerBarDelegate <NSObject>

@optional
// top
- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView backBT:(UIButton *)button;

// 默认只有右上角的按钮的话
- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView topRightBT:(UIButton *)button;

// 使用topBar自定义按钮的话, 使用这个接口.
- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView topCustomBT:(UIButton *)button;

// bottom
- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView landscapeBT:(UIButton *)button;

- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView playBT:(UIButton *)button;

- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView previousBT:(UIButton *)button;

- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView nextBT:(UIButton *)button;

- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView rateBT:(UIButton *)button;

- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView definitionBT:(UIButton *)button;

- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView videoNumBT:(UIButton *)button;

- (void)poporAvPlayerViewDidPlayEnd:(PoporAvPlayerView *)poporAvPlayerView;

- (BOOL)poporAvPlayerViewCheckNetPermission:(PoporAvPlayerView *)poporAvPlayerView;

@end

// MARK: 对外接口
@protocol PoporAvPlayerViewProtocol <NSObject>

- (UIView *)view;

// 显示控制条 或者延长控制条显示时间
- (void)showControlBar;

- (void)showController_startTimer;

- (void)showController_endTimer;


- (void)playVideoUrl:(NSURL *)videoURL seekTime:(CGFloat)seekTime;

// 开始执行事件,比如获取网络数据
- (void)startEvent;

- (void)startPlay;

- (void)pausePlay;

//- (void)stopPlay;

- (void)setRate:(CGFloat)rate;

- (void)setPlayTime:(CGFloat)playTime;

- (void)addBlurImage:(UIImage *)blurImage;

- (void)addDefaultBlurImage;

// 内部拖拽视频到某个时间点
- (void)innerDragVideoTimeTo:(CGFloat)second;

#pragma mark - bar action
// 原本内部的点击事件
- (void)landscapeButtonDidClick:(UIButton *)button;

- (void)previousBTDidClick:(UIButton *)button;

- (void)nextBTDidClick:(UIButton *)button;

- (void)topRightBtDidClick:(UIButton *)button;

- (void)rateBTDidClick:(UIButton *)button;

- (void)playButtonDidClick:(UIButton *)button;

- (void)videoNumBTDidClick:(UIButton *)button;


#pragma mark - 更新topBar 右边按钮数组
/**
 *  @brief 自定义 top right 部分按钮
 *
 *  @param btSize bt 按钮, if = CGSizeZero 则为(kJPVideoPlayerControlTopBarBTWidth, kJPVideoPlayerControlTopBarBTWidth)
 *
 */
- (void)updateTopBarRightBtArray:(NSArray<UIButton *> *)array xGap:(CGFloat)xGap btSize:(CGSize)btSize;

#pragma mark - 设置nc的侧滑gr, 防止和self.videoPanGR 手势冲突
- (void)videoPanGrFailGr:(UIGestureRecognizer *)ncPopGr;

// MARK: 自己的
@property (nonatomic, weak  ) id<PoporAvPlayerBarDelegate> delegate;

@property (nonatomic, strong) AVPlayer * avPlayer;
@property (nonatomic, strong) PoporAVPlayerLayer * avPlayerLayer;

@property (nonatomic, strong) PoporAvPlayerTopBar * topBar;
@property (nonatomic, strong) PoporAvPlayerBottomBar * bottomBar;

@property (nonatomic, strong) UITapGestureRecognizer * hiddenShowTapGR;
@property (nonatomic, strong) NSTimer * _Nullable hiddenBarTimer;

@property (nonatomic, strong) UITapGestureRecognizer * playPauseTapGR; // 双击暂停开始手势
@property (nonatomic, strong) UILongPressGestureRecognizer * longPressGR; // 长按开启快速播放功能

@property (strong, nonatomic) AVPlayerItem * _Nullable playerItem;

@property (nonatomic, weak  ) PoporAvPlayerRecord * record;

@property (nonatomic, strong) PoporAvPanGR * videoPanGR;

@property (assign, nonatomic) BOOL seekToZeroBeforePlay;// 假如需要重新播放,或者播放下一级的话

// MARK: 外部注入的
@property (nonatomic, copy  ) PoporAvPlayerBlock_layoutTopBar        block_layoutTopBar;
@property (nonatomic, copy  ) PoporAvPlayerBlock_layoutBottomBar     block_layoutBottomBar;
@property (nonatomic, copy  ) PoporAvPlayerBlock_layoutBottomBarTime block_layoutBottomBarTime;
@property (nonatomic, copy  ) PoporAvPlayerBlock_layoutTopBottomBar  block_layoutTopBottomBar;

@end

// MARK: 数据来源
@protocol PoporAvPlayerViewDataSource <NSObject>

@end

// MARK: UI事件
@protocol PoporAvPlayerViewEventHandler <NSObject>

- (void)playVideoUrl:(NSURL *)videoURL seekTime:(CGFloat)seekTime;

- (void)updateMonitorTimer;

- (void)beginScrub:(UISlider *)sender;
- (void)scrubbing:(UISlider *)sender;
- (void)endScrub:(UISlider *)sender;

@end

NS_ASSUME_NONNULL_END
