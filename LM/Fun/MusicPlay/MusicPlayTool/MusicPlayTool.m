//
//  MusicPlayer.m
//  LM
//
//  Created by apple on 2019/3/28.
//  Copyright © 2019 popor. All rights reserved.
//

#import "MusicPlayTool.h"
#import "MusicPlayBar.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MusicPlayTool() <AVAudioPlayerDelegate>

@property (nonatomic, getter=isNeedActive) BOOL needActive;

@property (nonatomic, weak  ) MusicPlayBar    * mpb;
@property (nonatomic, strong) NSDateFormatter * dateFormatterMS; // 分钟秒
@property (nonatomic, strong) NSDateFormatter * dateFormatter1HMS;// 1小时分钟秒
@property (nonatomic, strong) NSDateFormatter * dateFormatter10HMS;// 10小时分钟秒

@property (nonatomic, strong) MusicConfig * racSlideOB; // 为rac 充当监控的东西

@end

@implementation MusicPlayTool

+ (MusicPlayTool *)share {
    static dispatch_once_t once;
    static MusicPlayTool * instance;
    dispatch_once(&once, ^{
        instance = [self new];
        
        // 后台播放设置
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        //                   AVAudioSessionCategoryPlayback
        
        //[session setCategory:AVAudioSessionCategoryAmbient error:nil]; // 可以和后台音乐一起播放
        //NSLog(@"其他APP是否播放: %i", session.isOtherAudioPlaying);
        if (session.isOtherAudioPlaying) {
            instance.needActive = YES;
        }else{
            instance.needActive = NO;
            [session setActive:YES error:nil];
        }
        
        [instance initIosController];
        [instance initFormater];
       
        instance.defaultCoverImage = [UIImage imageNamed:@"music_placeholder"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            instance.mpb = MpbShare;
        });
        
    });
    return instance;
}

- (void)playItem:(MusicPlayItemEntity *)item autoPlay:(BOOL)autoPlay {
    NSString * path = [NSString stringWithFormat:@"%@/%@", FT_docPath, item.filePath];
    NSURL * url     = [NSURL fileURLWithPath:path];
    //self.musicTitle = item.fileName;
    self.musicItem  = item;
    
    if (self.audioPlayer && [self.audioPlayer.url isEqual:url]) {
        //[self.audioPlayer prepareToPlay];
        if (autoPlay) {
            [self playEvent];
        }
    }else{
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        self.audioPlayer.delegate = self;
        //[self.audioPlayer prepareToPlay];
        if (autoPlay) {
            [self playEvent];
        }
    }
    
    [self updateIosLockInfo];
}

- (void)playEvent {
    [self.audioPlayer play];
    
    // 设置 session active
    if (self.isNeedActive) {
        self.needActive = NO;
        AVAudioSession * session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
    }
    
    self.racSlideOB = [MusicConfig new];
    
    @weakify(self);
    [[[RACSignal interval:0.1 onScheduler:[RACScheduler mainThreadScheduler]] takeUntil:self.racSlideOB.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        if (!self.mpb.isSliderSelected) {
            self.mpb.slider.value = self.audioPlayer.currentTime/(float)self.audioPlayer.duration;
        }
        //CGFloat time = self.audioPlayer.currentTime *59;
        CGFloat time = self.audioPlayer.currentTime;
        
        [self.mpb updateTimeCurrentFrameTime:time];
        self.mpb.timeCurrentL.text = [self stringFromTime:time];
    }];
}

- (void)updateIosLockInfo {
    AVAudioPlayer * ap            = self.audioPlayer;
    MPNowPlayingInfoCenter * mpic = [MPNowPlayingInfoCenter defaultCenter];
    
    if (ap.duration > 0) {
        NSMutableDictionary *songInfo = [ [NSMutableDictionary alloc] init];
        {
            UIImage * coverImage = [MusicPlayTool imageOfUrl:self.audioPlayer.url];
            
            // UIColor * color = [self.defaultCoverImage colorAtPixel:CGPointMake(10, 10)];
            // 0.2 0.752941 0.745098 1
            // NSLog(@"1");
            
            if (coverImage) {
                CGSize size = CGSizeMake(self.mpb.coverIV.size.width*[UIScreen mainScreen].scale, self.mpb.coverIV.size.height*[UIScreen mainScreen].scale);
                self.mpb.coverIV.image = [UIImage imageFromImage:coverImage size:size];
                
                MPMediaItemArtwork *media;
#if TARGET_OS_MACCATALYST
                media = [[MPMediaItemArtwork alloc] initWithBoundsSize:size requestHandler:^UIImage * _Nonnull(CGSize size) {
                    return coverImage;
                }];
#else
                media = [[MPMediaItemArtwork alloc] initWithImage:coverImage];
#endif
                [songInfo setObject:media forKey:MPMediaItemPropertyArtwork];
                
            }else{
                self.mpb.coverIV.image = self.defaultCoverImage;
            }
            coverImage = nil;
        }
        //锁屏标题
        [songInfo setObject:[NSNumber numberWithFloat:self.audioPlayer.duration] forKey:MPMediaItemPropertyPlaybackDuration];
        [songInfo setObject:[NSNumber numberWithFloat:self.audioPlayer.currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        
        [songInfo setObject:self.musicItem.musicTitle forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:self.musicItem.musicAuthor forKey:MPMediaItemPropertyArtist];
        //[songInfo setObject:author forKey:MPMediaItemPropertyAlbumTitle];
        [mpic setNowPlayingInfo:songInfo];

        self.mpb.slider.value       = self.audioPlayer.currentTime/self.audioPlayer.duration;
        self.mpb.timeCurrentL.text  = [self stringFromTime:self.audioPlayer.currentTime];
        
        //CGFloat time = self.audioPlayer.duration +7200;
        CGFloat time = self.audioPlayer.duration;
        self.mpb.timeDurationL.text = [self stringFromTime:time];
        [self.mpb updateTimeDurationFrameTime:time];
        
        self.mpb.nameL.text         = [NSString stringWithFormat:@"%@ - %@", self.musicItem.musicAuthor, self.musicItem.musicTitle];
        
    }else{
        [mpic setNowPlayingInfo:nil];
    }
}

- (NSString *)stringFromTime:(int)time {
    return [NSDate clockText:time];
}

- (void)initIosController  {
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    // https://github.com/wsl2ls/LyricsAnalysis demo
    // https://www.jianshu.com/p/950fec0cdb21 详细
    // https://www.jianshu.com/p/87f3f2024038 拔耳机
    
    [commandCenter.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (MpbShare.playBT.isSelected) {
            [MpbShare pauseEvent];
        }else{
            [MpbShare playEvent];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [MpbShare playEvent];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [MpbShare pauseEvent];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        //NSLog(@"上一首");
        [MpbShare previousBTEvent];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        //NSLog(@"下一首");
        [MpbShare nextBTEvent];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    
    //togglePlayPauseCommand
    
    // 处理锁屏拖拽进度条事件
    @weakify(self);
    [commandCenter.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        @strongify(self);
        MPChangePlaybackPositionCommandEvent * playbackPositionEvent = (MPChangePlaybackPositionCommandEvent *)event;
        self.audioPlayer.currentTime = playbackPositionEvent.positionTime;
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 拔耳机
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)   name:AVAudioSessionRouteChangeNotification object:nil];//设置通知
    
    // 被其他APP打断
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
}

//通知方法的实现
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            //NSLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            //tipWithMessage(@"耳机插入");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:{
            NSLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            //tipWithMessage(@"耳机拔出，停止播放操作");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mpb pauseEvent];
            });
            break;
        }
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            //tipWithMessage(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

- (void)handleInterruption:(NSNotification *)notification {
    NSNumber *interruptionType      = [[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey];
    NSNumber *interruptionOptionKey = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey];
    if (interruptionType.integerValue == 1) {
        //NSLog(@"暂停");
        [self.mpb pauseEvent];
    }else if (interruptionOptionKey.integerValue == 1) {
        //NSLog(@"播放");
        [self.mpb playEvent];
    }
}

- (void)playAtTimeScale:(float)scale {
    self.audioPlayer.currentTime = self.audioPlayer.duration * scale;
    // 拖拽进度条后,需要刷新锁屏信息
    [self updateIosLockInfo];
}

- (void)pauseEvent {
    // 暂停的时候刷新锁屏信息,但是这会造成信息闪烁跳动,酷狗没有做这个刷新.
    [self updateIosLockInfo];
    [self.audioPlayer pause];
    self.racSlideOB = nil;
}

- (void)rewindEvent:(int)second {
    
}

- (void)forwardEvent:(int)second {
    
}

#pragma mark - delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (self.mpb.mplt.config.playOrder == McPlayOrderSingle) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.audioPlayer play];
        });
    }else{
        [MpbShare nextBTEvent];
    }
}

#pragma mark - init
- (void)initFormater {
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"mm:ss"];
        [df setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        self.dateFormatterMS = df;
    }
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"H:mm:ss"];
        [df setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        self.dateFormatter1HMS = df;
    }
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"HH:mm:ss"];
        [df setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        self.dateFormatter10HMS = df;
    }
}

#pragma mark - tool
+ (UIImage *)imageOfUrl:(NSURL *)url {
    UIImage * coverImage;
    // 设置封面
    AVURLAsset *avURLAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
    for (NSString * format in [avURLAsset availableMetadataFormats]){
        for (AVMetadataItem *metadata in [avURLAsset metadataForFormat:format]){
            if([metadata.commonKey isEqualToString:@"artwork"]){
                NSData*data = [metadata.value copyWithZone:nil];
                coverImage = [UIImage imageWithData:data];
                break;
            }
        }
        if (coverImage) {
            break;
        }
    }
    return coverImage;
    //
    //    UIImage * coverImage;
    //    // 设置封面
    //    AVURLAsset *avURLAsset = [[AVURLAsset alloc] initWithURL:self.audioPlayer.url options:nil];
    //    for (NSString * format in [avURLAsset availableMetadataFormats]){
    //        for (AVMetadataItem *metadata in [avURLAsset metadataForFormat:format]){
    //            // NSLog(@"metadata.commonKey: %@", metadata.commonKey);
    //            // if([metadata.commonKey isEqualToString:@"title"]){
    //            //     NSString *title = (NSString *)metadata.value;//提取歌曲名
    //            // }
    //            if([metadata.commonKey isEqualToString:@"artwork"]){
    //                NSData*data = [metadata.value copyWithZone:nil];
    //                coverImage = [UIImage imageWithData:data];
    //                MPMediaItemArtwork *media = [[MPMediaItemArtwork alloc] initWithImage:coverImage];
    //                [songInfo setObject:media forKey:MPMediaItemPropertyArtwork];
    //            }//还可以提取其他所需的信息
    //        }
    //    }
    //    if (coverImage) {
    //        self.mpb.coverIV.image = [UIImage imageFromImage:coverImage size:CGSizeMake(self.mpb.coverIV.size.width*[UIScreen mainScreen].scale, self.mpb.coverIV.size.height*[UIScreen mainScreen].scale)];
    //    }else{
    //        self.mpb.coverIV.image = [UIImage imageNamed:@"music_placeholder"];
    //    }
    //    coverImage = nil;
    
}

@end
