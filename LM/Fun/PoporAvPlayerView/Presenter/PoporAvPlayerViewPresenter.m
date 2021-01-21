//
//  PoporAvPlayerViewPresenter.m
//  hywj
//
//  Created by popor on 2020/9/5.
//  Copyright © 2020 popor. All rights reserved.

#import "PoporAvPlayerViewPresenter.h"
#import "PoporAvPlayerViewInteractor.h"

#import <ReactiveObjC/ReactiveObjC.h>
#import "PoporAvPlayerRecord.h"

NSString * const kTracksKey   = @"tracks";
NSString * const kPlayableKey = @"playable";
NSString * const kStatusKey   = @"status";

@interface PoporAvPlayerViewPresenter ()

@property (nonatomic, weak  ) id<PoporAvPlayerViewProtocol> view;
@property (nonatomic, strong) PoporAvPlayerViewInteractor * interactor;

@property (strong, nonatomic) id                  timeObserver;
@property (assign, nonatomic) CGFloat             mRestoreAfterScrubbingRate;

@property (assign, nonatomic) BOOL                becomeActiveNeedReplay;// 激活APP之后, 是否继续播放.

@property (nonatomic, weak  ) PoporAvPlayerRecord * record;
@property (nonatomic, copy  ) NSURL               * lastVideoURL;

@end

@implementation PoporAvPlayerViewPresenter

- (id)init {
    if (self = [super init]) {
        self.record = [PoporAvPlayerRecord share];
        
        // 系统 进入前台后台通知事件
        @weakify(self);
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillResignActiveNotification object:nil] takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
            @strongify(self);
            [self applicationWillResignActive:x];
        }];
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
            @strongify(self);
            [self applicationDidBecomeActive:x];
        }];
    }
    return self;
}

- (void)setMyInteractor:(PoporAvPlayerViewInteractor *)interactor {
    self.interactor = interactor;
    
}

- (void)setMyView:(id<PoporAvPlayerViewProtocol>)view {
    self.view = view;
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    
}

#pragma mark - 系统 进入前台后台通知事件
- (void)applicationWillResignActive:(NSNotification *)notification {
    if ([self.view.bottomBar isPlayBTStatus_playing]) {
        self.becomeActiveNeedReplay = YES;
        [self.view pausePlay];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (self.becomeActiveNeedReplay) {
        [self.view startPlay];
        self.becomeActiveNeedReplay = NO;
    }
}

- (void)playVideoUrl:(NSURL *)videoURL seekTime:(CGFloat)seekTime {
    NSError *error = nil;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (!success) {
        AlertToastTitle(@"无法播放");
        return;
    }
    
    if ([self.lastVideoURL.absoluteString isEqualToString:videoURL.absoluteString]) {
        if (self.view.record.totalSeconds > 0) {
            if (self.view.record.totalSeconds -seekTime <= 1) { // 假如当前视频
                [self.view setPlayTime:0];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.view startPlay];
                });
            } else {
                if (![self.view.bottomBar isPlayBTStatus_playing]) {
                    [self.view setPlayTime:seekTime];
                }
            }
        } else {
            [self.view startPlay];
        }
        return;
    } else {
        // 先暂停之前的
        if (self.lastVideoURL) {
            [self.view.avPlayer pause];
        }
        
        // 替换之前播放源
        if (self.view.playerItem) {
            self.view.playerItem = nil;
            [self.view.avPlayer replaceCurrentItemWithPlayerItem:nil];
        }
        
        [self.view.bottomBar setTimeLabelValues:0 totalTime:0];
        self.view.bottomBar.progressSlider.maximumValue = 0;
        self.view.bottomBar.progressSlider.value        = 0;
        self.view.bottomBar.bufferProgressView.progress = 0; // 更新缓冲进度
        
        self.view.record.currentTime    = 0;
        self.view.record.elapsedSeconds = 0;
        self.view.record.totalSeconds   = 0;
    }
    self.lastVideoURL = videoURL;
    
    @weakify(self);
    AVURLAsset *asset      = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];
    
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
        dispatch_async( dispatch_get_main_queue(), ^{
            @strongify(self);
            
            /* Make sure that the value of each key has loaded successfully. */
            for (NSString *thisKey in requestedKeys) {
                NSError *error = nil;
                AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
                if (keyStatus == AVKeyValueStatusFailed) {
                    [self assetFailedToPrepareForPlayback:error];
                    return;
                }
            }
            NSError* error = nil;
            AVKeyValueStatus status = [asset statusOfValueForKey:kTracksKey error:&error];
            if (status == AVKeyValueStatusLoaded) {
                
                // 假如有延迟, 收到通知时候的url 和 现在最新的url不一致, 则不执行.
                if (![asset.URL.absoluteString isEqualToString:self.lastVideoURL.absoluteString]) {
                    return;
                }
                self.view.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                [self.view.avPlayer replaceCurrentItemWithPlayerItem:self.view.playerItem];
                
                {
                    // 监听 通知
                    RACSignal *signal = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.view.playerItem] takeUntil:[self.view.playerItem rac_willDeallocSignal]];
                    [signal subscribeNext:^(NSNotification * _Nullable x) {
                        @strongify(self);
                        
                        [self playerItemDidReachEnd];
                    }];
                    [signal subscribeCompleted:^{
                        //NSLog(@"%@", @"通知被移除");
                    }];
                }
                self.view.seekToZeroBeforePlay = NO;
                
                [[RACObserve(self.view.playerItem, status) takeUntil:[self.view.playerItem rac_willDeallocSignal]] subscribeNext:^(id  _Nullable x) {
                    @strongify(self);
                    AVPlayerItem * item = self.view.playerItem;
                    [self.view showControlBar];
                    
                    switch (item.status) {
                            /* Indicates that the status of the player is not yet known because
                             it has not tried to load new media resources for playback */
                        case AVPlayerStatusUnknown: {
                            [self removePlayerTimeObserver];
                            [self disableScrubber];
                            [self disablePlayerButtons];
                            break;
                        }
                        case AVPlayerStatusReadyToPlay: {
                            /* Once the AVPlayerItem becomes ready to play, i.e.
                             [playerItem status] == AVPlayerItemStatusReadyToPlay,
                             its duration can be fetched from the item. */
                            [self updateMonitorTimer];
                            [self enableScrubber];
                            [self enablePlayerButtons];
                            
                            [self.view.bottomBar setPlayBTStatus_playing];
                            
                            break;
                        }
                        case AVPlayerStatusFailed: {
                            [self assetFailedToPrepareForPlayback:item.error];
                            [self.view.bottomBar setPlayBTStatus_pause];
                            break;
                        }
                    }
                    
                }];
                
                if (seekTime > 0) {
                    [self.view.avPlayer seekToTime:CMTimeMakeWithSeconds(seekTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
                }
                [self.view startPlay];
                
            } else {
                NSLog(@"Failed to load the tracks.");
            }
        });
    }];
}

#pragma mark - slider progress management
- (void)updateMonitorTimer {
    [self removePlayerTimeObserver];
    [self addPlayerTimeObserver];
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.view.avPlayer currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark - 拖拽进度条事件
- (void)beginScrub:(UISlider *)sender {
    self.record.chontrolHiddenPause = YES;
    self.mRestoreAfterScrubbingRate = [self.view.avPlayer rate];
    [self.view.avPlayer setRate:0];
    
    /* Remove previous timer. */
    [self removePlayerTimeObserver];
}

- (void)scrubbing:(UISlider *)sender {
    double currentTime = floor(sender.value);
    double totalTime   = floor([self duration]);
    [self.view.bottomBar setTimeLabelValues:currentTime totalTime:totalTime];
}

- (void)endScrub:(UISlider *)sender {
    
    [self.view innerDragVideoTimeTo:floor(sender.value)];
    [self.view showControlBar]; // self.record.chontrolHiddenPause = NO; 前面的方法已经包含此条.
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.mRestoreAfterScrubbingRate > 0) {
            [self.view.avPlayer setRate:self.mRestoreAfterScrubbingRate];
            self.mRestoreAfterScrubbingRate = 0;
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.timeObserver) {
            [self.view startPlay];
        }
    });
    
}

#pragma mark -
- (void)assetFailedToPrepareForPlayback:(NSError *)error {
    [self removePlayerTimeObserver];
    [self disableScrubber];
    [self disablePlayerButtons];
}

// 视频播放完成
- (void)playerItemDidReachEnd {
    self.view.seekToZeroBeforePlay = YES;
    [self.view.bottomBar setPlayBTStatus_pause];
    [self.view.record pauseEvent];
    
    [self.view showController_startTimer];
    
    if (self.view.delegate && [self.view.delegate respondsToSelector:@selector(poporAvPlayerViewDidPlayEnd:)]) {
        [self.view.delegate poporAvPlayerViewDidPlayEnd:(PoporAvPlayerView *)self.view];
    }
}

- (void)addPlayerTimeObserver {
    CGFloat monitorTime = self.view.avPlayer.rate==0 ? 1 : 1/self.view.avPlayer.rate;
    monitorTime = MIN(1, monitorTime);
    monitorTime = 0.2;
    
    @weakify(self);
    self.timeObserver = [self.view.avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(monitorTime, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
        @strongify(self);
        
        
        double duration    = CMTimeGetSeconds(self.view.avPlayer.currentItem.duration);
        double currentTime = MIN(CMTimeGetSeconds(time), duration); // 防止播放时间大于总时间.
        //[self currentTime:currentTime cacheTime:cacheTime duration:duration];
        
        self.view.record.currentTime    = currentTime;
        self.view.record.elapsedSeconds = currentTime;
        self.view.record.totalSeconds   = duration;
        
        [self.view.bottomBar setTimeLabelValues:currentTime totalTime:duration];
        // 更新播放进度
        if (!isnan(duration)) {
            self.view.bottomBar.progressSlider.maximumValue = ceil(duration);
            self.view.bottomBar.progressSlider.value        = ceil(currentTime);
            // 更新缓冲进度
            double cacheTime   = [self availableDuration];
            self.view.bottomBar.bufferProgressView.progress = cacheTime / duration;
        }
        
    }];
}

/* Cancels the previously registered time observer. */
- (void)removePlayerTimeObserver {
    if (self.timeObserver) {
        [self.view.avPlayer removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

#pragma mark - Tools
- (double)duration{
    if(self.view.avPlayer.currentItem){
        CMTime durationTime = self.view.avPlayer.currentItem.duration;
        return CMTimeGetSeconds(durationTime);
    }
    return 0;
}

- (void)enableScrubber {
    self.view.bottomBar.progressSlider.enabled = YES;
}

- (void)disableScrubber {
    self.view.bottomBar.progressSlider.enabled = NO;
}

- (void)enablePlayerButtons {
    self.view.bottomBar.playButton.enabled = YES;
}

- (void)disablePlayerButtons {
    self.view.bottomBar.playButton.enabled = YES;
}

@end

//- (BOOL)isPlaying {
//    return self.mRestoreAfterScrubbingRate != 0.f || [self.view.avPlayer rate] != 0.f;
//}
