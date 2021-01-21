//
//  PoporAvPlayerView.m
//  hywj
//
//  Created by popor on 2020/9/5.
//  Copyright © 2020 popor. All rights reserved.

#import "PoporAvPlayerView.h"
#import "PoporAvPlayerViewPresenter.h"
#import "PoporAvPlayerViewInteractor.h"
#import "PoporAvPlayerRecord.h"

#import "FeedbackGeneratorTool.h"

static int GLViewIndex0     = 0;
//static int GLControllIndex1 = 1;

@interface PoporAvPlayerView () <PoporAvPlayerBottomBarDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) PoporAvPlayerViewPresenter * present;
@property (nonatomic        ) CGFloat beforePlayRate;

@end

@implementation PoporAvPlayerView

@synthesize delegate;
@synthesize avPlayer;
@synthesize avPlayerLayer;
@synthesize topBar;
@synthesize bottomBar;
@synthesize hiddenShowTapGR;
@synthesize hiddenBarTimer;
@synthesize playerItem;
@synthesize playPauseTapGR;
@synthesize record;
@synthesize videoPanGR;
@synthesize longPressGR;
@synthesize seekToZeroBeforePlay;
@synthesize block_layoutTopBar;
@synthesize block_layoutBottomBar;
@synthesize block_layoutBottomBarTime;
@synthesize block_layoutTopBottomBar;
//@synthesize weakNcPopGr;

- (instancetype)init {
    return [self initWithDic:nil];
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [self assembleViper];
        
    }
    return self;
}

#pragma mark - VCProtocol
- (UIView *)view {
    return self;
}

#pragma mark - viper views
- (void)assembleViper {
    if (!self.present) {
        PoporAvPlayerViewPresenter * present = [PoporAvPlayerViewPresenter new];
        PoporAvPlayerViewInteractor * interactor = [PoporAvPlayerViewInteractor new];
        
        self.present = present;
        [present setMyInteractor:interactor];
        [present setMyView:self];
        
        [self addViews];
        [self startEvent];
    }
}

- (void)addViews {
    self.backgroundColor = [UIColor blackColor];
    self.record = [PoporAvPlayerRecord share];
    
    [self addAvPlayers];
    [self addBars];
    [self addBarBtAction];
    [self addGrs];
    [self addVideoPanViews];
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    [self.present startEvent];
    
}

// -----------------------------------------------------------------------------
- (void)addAvPlayers {
    if (!self.avPlayer) {
        self.avPlayer = [[AVPlayer alloc] init];
        
    }
    if (!self.avPlayerLayer) {
        self.avPlayerLayer = [[PoporAVPlayerLayer alloc] init];
        //self.avPlayerLayer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [self.view insertSubview:self.avPlayerLayer atIndex:GLViewIndex0];
        AVPlayerLayer * layer = (AVPlayerLayer *)self.avPlayerLayer.layer;
        [layer setPlayer:self.avPlayer];
    }
    
    [self.avPlayerLayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
}

- (void)addBars {
    self.blurImageView = ({
        UIImageView * oneIV = [UIImageView new];
        oneIV.userInteractionEnabled = NO;
        
        [self addSubview:oneIV];
        oneIV;
    });
    
    self.topBar = ({
        PoporAvPlayerTopBar * bar = [PoporAvPlayerTopBar new];
        
        [self addSubview:bar];
        
        bar;
    });
    
    self.bottomBar = ({
        PoporAvPlayerBottomBar * bar = [PoporAvPlayerBottomBar new];
        bar.delegate = self;
        [self addSubview:bar];
        
        bar;
    });
    
    [self.blurImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    // 使用自定义masonry, 或者默认masonry
    if (self.block_layoutTopBottomBar) {
        self.block_layoutTopBottomBar(self.topBar, self.bottomBar);
    } else {
        [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            
            make.height.mas_equalTo(kJPVideoPlayerControlTopBarHeight);
        }];
        [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(0);
            
            make.height.mas_equalTo(kJPVideoPlayerControlBarHeight);
        }];
    }
    
    if (self.block_layoutTopBar) {
        self.block_layoutTopBar(self.topBar);
    } else {
        [self.topBar defalutMasonry];
    }
    if (self.block_layoutBottomBar) {
        self.block_layoutBottomBar(self.bottomBar);
    } else {
        [self.bottomBar defalutMasonry];
    }
}


#pragma mark - bar action
- (void)addBarBtAction {
    [self.topBar.backBT             addTarget:self action:@selector(backBTDidClick:)          forControlEvents:UIControlEventTouchUpInside];
    [self.topBar.rightBT            addTarget:self action:@selector(topRightBtDidClick:)      forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomBar.playButton      addTarget:self action:@selector(playButtonDidClick:)      forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar.playButton_mini addTarget:self action:@selector(playButtonDidClick:)      forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar.previousBT      addTarget:self action:@selector(previousBTDidClick:)      forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar.nextBT          addTarget:self action:@selector(nextBTDidClick:)          forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomBar.videoNumBT      addTarget:self action:@selector(videoNumBTDidClick:)      forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar.rateBT          addTarget:self action:@selector(rateBTDidClick:)          forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar.definitionBT    addTarget:self action:@selector(definitionBTDidClick:)    forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar.landscapeButton addTarget:self action:@selector(landscapeButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomBar.progressSlider  addTarget:self.present action:@selector(beginScrub:)      forControlEvents:UIControlEventTouchDown];
    [self.bottomBar.progressSlider  addTarget:self.present action:@selector(scrubbing:)       forControlEvents:UIControlEventValueChanged];
    [self.bottomBar.progressSlider  addTarget:self.present action:@selector(endScrub:)        forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar.progressSlider  addTarget:self.present action:@selector(endScrub:)        forControlEvents:UIControlEventTouchUpOutside];
    [self.bottomBar.progressSlider  addTarget:self.present action:@selector(endScrub:)        forControlEvents:UIControlEventTouchCancel];
}

- (void)backBTDidClick:(UIButton *)button {
    self.record.chontrolHiddenTime = kJPControlViewAutoHiddenTimeInterval;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(poporAvPlayerView:backBT:)]) {
        [self.delegate poporAvPlayerView:self backBT:button];
    } else {
        NSLog(@"!!! %s 未实现", __func__);
    }
}

- (void)topRightBtDidClick:(UIButton *)button {
    self.record.chontrolHiddenTime = kJPControlViewAutoHiddenTimeInterval;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(poporAvPlayerView:topRightBT:)]) {
        [self.delegate poporAvPlayerView:self topRightBT:button];
    } else {
        NSLog(@"!!! %s 未实现", __func__);
    }
}

- (void)topCustomBtDidClick:(UIButton *)button {
    self.record.chontrolHiddenTime = kJPControlViewAutoHiddenTimeInterval;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(poporAvPlayerView:topCustomBT:)]) {
        [self.delegate poporAvPlayerView:self topCustomBT:button];
    } else {
        NSLog(@"!!! %s 未实现", __func__);
    }
}

- (void)playButtonDidClick:(UIButton *)button {
    self.record.chontrolHiddenTime = kJPControlViewAutoHiddenTimeInterval;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(poporAvPlayerView:playBT:)]) {
        [self.delegate poporAvPlayerView:self playBT:button];
    } else {
        if ([self.bottomBar isPlayBTStatus_playing]) {
            [self pausePlay];
            [self.record pauseEvent];
        } else {
            [self startPlay];
            [self.record playEvent];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setRate:self.avPlayer.rate];
            });
        }
    }
}

- (void)landscapeButtonDidClick:(UIButton *)button {
    self.record.chontrolHiddenTime = kJPControlViewAutoHiddenTimeInterval;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(poporAvPlayerView:landscapeBT:)]) {
        [self.delegate poporAvPlayerView:self landscapeBT:button];
    } else {
        button.selected = !button.selected;
        
        // wkq
        // self.playerView.jp_viewInterfaceOrientation == JPVideoPlayViewInterfaceOrientationPortrait ? [self.playerView jp_gotoLandscape] : [self.playerView jp_gotoPortrait];
    }
}

- (void)previousBTDidClick:(UIButton *)button {
    self.record.chontrolHiddenTime = kJPControlViewAutoHiddenTimeInterval;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(poporAvPlayerView:previousBT:)]) {
        [self.delegate poporAvPlayerView:self previousBT:button];
    } else {
        NSLog(@"!!! %s 未实现", __func__);
    }
}

- (void)nextBTDidClick:(UIButton *)button {
    self.record.chontrolHiddenTime = kJPControlViewAutoHiddenTimeInterval;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(poporAvPlayerView:nextBT:)]) {
        [self.delegate poporAvPlayerView:self nextBT:button];
    } else {
        NSLog(@"!!! %s 未实现", __func__);
    }
}

- (void)rateBTDidClick:(UIButton *)button {
    self.record.chontrolHiddenTime = kJPControlViewAutoHiddenTimeInterval;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(poporAvPlayerView:rateBT:)]) {
        [self.delegate poporAvPlayerView:self rateBT:button];
    } else {
        NSLog(@"!!! %s 未实现", __func__);
    }
}

- (void)definitionBTDidClick:(UIButton *)button {
    self.record.chontrolHiddenTime = kJPControlViewAutoHiddenTimeInterval;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(poporAvPlayerView:definitionBT:)]) {
        [self.delegate poporAvPlayerView:self definitionBT:button];
    } else {
        NSLog(@"!!! %s 未实现", __func__);
    }
}

- (void)videoNumBTDidClick:(UIButton *)button {
    self.record.chontrolHiddenTime = kJPControlViewAutoHiddenTimeInterval;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(poporAvPlayerView:videoNumBT:)]) {
        [self.delegate poporAvPlayerView:self videoNumBT:button];
    } else {
        NSLog(@"!!! %s 未实现", __func__);
    }
}

- (void)addGrs {
    {
        self.hiddenShowTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDidTap)];
        [self addGestureRecognizer:self.hiddenShowTapGR];
        [self showController_startTimer];
    }
    {
        self.playPauseTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playPauseTapGRAction:)];
        self.playPauseTapGR.numberOfTapsRequired = 2;
        
        [self addGestureRecognizer:self.playPauseTapGR];
    }
    [self.hiddenShowTapGR requireGestureRecognizerToFail:self.playPauseTapGR];
    {
        self.longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGRAction:)];
        self.longPressGR.minimumPressDuration = 1;
        
        [self addGestureRecognizer:self.longPressGR];
    }
}

#pragma mark - 单击手势
- (void)tapGestureDidTap {
    if (self.hiddenBarTimer) {
        [self showController_endTimer];
    } else {
        [self showController_startTimer];
    }
}

- (void)showControlBar {
    if (!self.hiddenBarTimer) { // 因为存在单纯关闭timer但是不关闭控制条的情况, 例如视频url为空的时候,视频控制条常显.
        [self showController_startTimer];
    } else {
        self.record.chontrolHiddenTime = kJPControlViewAutoHiddenTimeInterval;
    }
}

- (void)showController_startTimer {
    self.record.chontrolHiddenPause = NO;
    self.record.chontrolHiddenTime = kJPControlViewAutoHiddenTimeInterval;
    
    if(!self.hiddenBarTimer){
        self.hiddenBarTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timeDidChange:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.hiddenBarTimer forMode:NSRunLoopCommonModes];
        
        if (self.record.hiddenControlBarBlock) {
            self.record.hiddenControlBarBlock(NO);
        }
        
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.topBar.alpha        = 1;
            self.bottomBar.alpha     = 1;
            self.blurImageView.alpha = 1;
            
        } completion:^(BOOL finished) { }];
    }
}

- (void)showController_endTimer {
    if(self.hiddenBarTimer){
        [self.hiddenBarTimer invalidate];
        self.hiddenBarTimer = nil;
        
        if (self.record.hiddenControlBarBlock) {
            self.record.hiddenControlBarBlock(YES);
        }
        
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.topBar.alpha        = 0;
            self.bottomBar.alpha     = 0;
            self.blurImageView.alpha = 0;
            
        } completion:^(BOOL finished) { }];
    }
}

- (void)timeDidChange:(NSTimer *)timer {
    if (self.record.chontrolHiddenPause) {
        return;
    }
    self.record.chontrolHiddenTime--;
    if (self.record.chontrolHiddenTime <= 0) {
        [self showController_endTimer];
    }
}

#pragma mark - 手势
// 双击手势
- (void)playPauseTapGRAction:(UITapGestureRecognizer *)tapGR {
    
    CGPoint point = [tapGR locationInView:self];
    
    if (point.x <= self.view.width *0.33) {
        if (self.record.currentTime >10) {
            [self setPlayTime:self.record.currentTime -10];
        } else {
            [self setPlayTime:0];
        }
        
        if (self.bottomBar.playButton.isSelected) {
            [self playButtonDidClick:self.bottomBar.playButton];
        }
    } else if (point.x >= self.view.width *0.66) {
        if (self.record.totalSeconds -self.record.currentTime >10) {
            [self setPlayTime:self.record.currentTime +10];
        }
        
        if (self.bottomBar.playButton.isSelected) {
            [self playButtonDidClick:self.bottomBar.playButton];
        }
    } else {
        [self playButtonDidClick:self.bottomBar.playButton];
        
        if (!self.hiddenBarTimer) {
            [self showController_startTimer];
        }
    }
    
    [self showControlBar];
}

// 长按手势
- (void)longPressGRAction:(UILongPressGestureRecognizer *)pressGR {
    switch (pressGR.state) {
        case UIGestureRecognizerStateBegan: {
            self.beforePlayRate = self.avPlayer.rate;
            [self setRate:2.0];
            
            break;
        }
        default: {
            [self setRate:self.beforePlayRate];
            break;
        }
    }
    
}

#pragma mark - 对外接口
- (void)playVideoUrl:(NSURL *)videoURL seekTime:(CGFloat)seekTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.present playVideoUrl:videoURL seekTime:seekTime];
        [self.bottomBar setPlayBTStatus_playing];
    });
}

- (void)startPlay {
    if (self.seekToZeroBeforePlay) {
        self.seekToZeroBeforePlay = NO;
        [self.avPlayer seekToTime:kCMTimeZero];
    }
    [self.avPlayer play];
    
    if (self.record.elapsedSeconds == self.record.totalSeconds && self.record.elapsedSeconds != 0) {
        [self setPlayTime:0];
        [self.bottomBar setPlayBTStatus_playing];
    } else {
        [self.bottomBar setPlayBTStatus_playing];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.bottomBar setPlayBTStatus_playing];
    });
}

- (void)pausePlay {
    [self.avPlayer pause];
    [self.bottomBar setPlayBTStatus_pause];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    });
}

- (void)setRate:(CGFloat)rate {
    self.avPlayer.rate = rate;
    [self.present updateMonitorTimer];
}

- (void)setPlayTime:(CGFloat)playTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.avPlayer seekToTime:CMTimeMakeWithSeconds(playTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    });
}

- (void)addBlurImage:(UIImage *)blurImage {
    self.blurImageView.image = blurImage;
}

- (void)addDefaultBlurImage {
    CGFloat color1 = 0.65;
    CGFloat color2 = 0.35;
    CGFloat color3 = 0.05;
    CGFloat color4 = 0.0;
    
    NSArray * colors =
    @[    PRGBF(0, 0, 0, color1)
          , PRGBF(0, 0, 0, color2)
          , PRGBF(0, 0, 0, color3)
          , PRGBF(0, 0, 0, color4)
          
          , PRGBF(0, 0, 0, color4)
          , PRGBF(0, 0, 0, color3)
          , PRGBF(0, 0, 0, color2)
          , PRGBF(0, 0, 0, color1)
    ];
    
    NSArray * locations =
    @[    @(0.0)
          , @(0.2)
          , @(0.30)
          , @(0.35)
          , @(0.5)
          , @(0.55)
          , @(0.7)
          , @(1.0)
    ];// 区间
    
    [self addBlurImage:[UIImage imageFromLayer:[UIImage gradientLayer:self.bounds colors:colors locations:locations start:CGPointMake(0, 0) end:CGPointMake(0, 1)]]];
}

#pragma mark - 增加屏幕亮度,声音,进度条事件.
- (void)addVideoPanViews {
    self.videoPanGR = ({
        PoporAvPanGR  * panView = [PoporAvPanGR new];
        panView.panGr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragPanGrAction:)];
        [self addGestureRecognizer:panView.panGr];
        
        //        if (self.navigationController.interactivePopGestureRecognizer) {
        //            [panView.pan requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
        //        }
        
        panView;
    });
}

- (void)dragPanGrAction:(UIPanGestureRecognizer *)gestureRecognizer {
    PoporAvPanGR * panGR = self.videoPanGR;
    UIView * baseView  = gestureRecognizer.view;
    CGPoint p          = [gestureRecognizer locationInView:baseView];
    
    PoporAvPlayerRecord * record = [PoporAvPlayerRecord share];
    static NSInteger tag = 0;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            [FeedbackGeneratorTool selectionFgPrepare];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            tag++;
            if (tag %10 == 0) {
                [FeedbackGeneratorTool selectionFgChange];
            }
            break;
        }
        default:{
            tag = 0;
            [FeedbackGeneratorTool selectionFgEnd];
            break;
        }
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        panGR.lastPoint = p;
        CGPoint velocty = [gestureRecognizer velocityInView:baseView];
        //NSLogPoint(velocty);
        if (fabs(velocty.x) > fabs(velocty.y)) {
            // 左右滑动seek播放
            if (self.delegate && [self.delegate respondsToSelector:@selector(poporAvPlayerViewCheckNetPermission:)]) {
                if ([self.delegate poporAvPlayerViewCheckNetPermission:self]) {
                    if (record.totalSeconds > 0) { //NSLog(@"视频 进度");
                        [panGR showSeekAtView:self];
                        panGR.seekSlider.value = record.elapsedSeconds/record.totalSeconds;
                        
                        panGR.panType = VideoPlayBackVCPanType_seek;
                        
                        [self showControlBar];
                        self.record.chontrolHiddenPause = YES;
                    }
                }
            } else {
                if (record.totalSeconds > 0) { //NSLog(@"视频 进度");
                    [panGR showSeekAtView:self];
                    panGR.seekSlider.value = record.elapsedSeconds/record.totalSeconds;
                    
                    panGR.panType = VideoPlayBackVCPanType_seek;
                }
            }
            
        } else {
            if (panGR.lastPoint.x > baseView.bounds.size.width * 0.5) {//在屏幕右边，上下滑动调整声音
                panGR.panType = VideoPlayBackVCPanType_volume;
                //NSLog(@"视频 声音");
            } else {//在屏幕左边，上下滑动调整亮度
                panGR.panType = VideoPlayBackVCPanType_brightness;
                //NSLog(@"视频 亮度");
                [panGR startShowBrightness];
            }
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged || gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        switch (panGR.panType) {
            case VideoPlayBackVCPanType_seek: {
                CGFloat dx = p.x - panGR.lastPoint.x;
                CGFloat value  = [PoporAvPanGR valueOfDistance:dx baseValue:panGR.seekSlider.value scale:0];
                CGFloat second = value * record.totalSeconds;
                panGR.seekSlider.value   = value;
                panGR.seekTimeLable.text = [PoporAvPanGR timeText:second];
                
                if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
                    [panGR hiddenSeek];
                    [self innerDragVideoTimeTo:second];
                }
                break;
            }
            case VideoPlayBackVCPanType_volume: {
                CGFloat dy = panGR.lastPoint.y - p.y;
                [panGR changeVolume:dy atView:self.view];
                break;
            }
            case VideoPlayBackVCPanType_brightness: {
                CGFloat dy = panGR.lastPoint.y - p.y;
                [panGR changeBrightness:dy];
                break;
            }
            default:
                break;
        }
        panGR.lastPoint = p;
    }
}

// 内部拖拽视频到某个时间点
- (void)innerDragVideoTimeTo:(CGFloat)second {
    self.seekToZeroBeforePlay = NO;
    self.record.chontrolHiddenPause = NO;
    self.record.elapsedSeconds = second;
    [self setPlayTime:second];
    [self setRate:self.avPlayer.rate];
    
    if (self.record.totalSeconds -second <= 1) {
        // 假如拖拽到最后1秒以内的话, 就不进行播放检查了.
    } else {
        if (![self.bottomBar isPlayBTStatus_playing]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startPlay];
            });
        }
    }
}

#pragma mark - PoporAvPlayerBottomBarDelegate
- (BOOL)poporAvPlayerBottomBar:(PoporAvPlayerBottomBar *)poporAvPlayerBottomBar currentTime:(double)currentTime totalTime:(double)totalTime {
    if (self.block_layoutBottomBarTime) {
        self.block_layoutBottomBarTime(poporAvPlayerBottomBar, currentTime, totalTime);
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - 更新topBar 右边按钮数组
- (void)updateTopBarRightBtArray:(NSArray<UIButton *> *)array xGap:(CGFloat)xGap btSize:(CGSize)btSize {
    if (array.count > 0) {
        [self.topBar updateRightBtArray:array xGap:xGap btSize:btSize];
        
        [self.topBar.rightBT removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        for (UIButton * bt in array) {
            [bt addTarget:self action:@selector(topCustomBtDidClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

#pragma mark - 设置nc的侧滑gr, 防止和self.videoPanGR 手势冲突
- (void)videoPanGrFailGr:(UIGestureRecognizer *)ncPopGr {
    [self.videoPanGR.panGr requireGestureRecognizerToFail:ncPopGr];
}

@end
