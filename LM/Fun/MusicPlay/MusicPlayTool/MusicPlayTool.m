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
#import "MusicPlayListTool.h"
#import "LrcTool.h"

@interface MusicPlayTool() <AVAudioPlayerDelegate>

@property (nonatomic, getter=isNeedActive) BOOL needActive;

@property (nonatomic, weak  ) MusicPlayBar    * mpb;
@property (nonatomic, strong) NSDateFormatter * dateFormatterMS; // 分钟秒
@property (nonatomic, strong) NSDateFormatter * dateFormatter1HMS;// 1小时分钟秒
@property (nonatomic, strong) NSDateFormatter * dateFormatter10HMS;// 10小时分钟秒

@property (nonatomic, strong) MusicConfig * racSlideOB; // 为rac 充当监控的东西

@property (nonatomic, copy  ) NSString * lastImageUrl;
//@property (nonatomic, copy  ) UIImage  * lastImage;

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
        
        [instance addMgjrouter];
    });
    return instance;
}

- (void)addMgjrouter {
    @weakify(self);
    [MRouterC registerURL:MUrl_playAtTime toHandel:^(NSDictionary *routerParameters){
        @strongify(self);
        
        NSMutableDictionary * dic = [MRouterC mixDic:routerParameters];
        NSString * time = dic[@"time"];
        
        self.audioPlayer.currentTime = time.floatValue;
        // 拖拽进度条后,需要刷新锁屏信息
        [self updateIosLockInfo];
    }];
}

- (void)playItem:(FileEntity *)item autoPlay:(BOOL)autoPlay {
#if TARGET_OS_MACCATALYST
    NSString * path = [NSString stringWithFormat:@"%@/%@/%@", FT_docPath, MusicFolderName, item.filePath];
#else
    NSString * path = [NSString stringWithFormat:@"%@/%@", FT_docPath, item.filePath];
#endif
    
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
    
    self.racSlideOB = nil;
    self.racSlideOB = [MusicConfig new];
    
    @weakify(self);
    CGFloat monitorTime = LrcMonitor0_1S ? 0.1:0.01 ;
    [[[RACSignal interval:monitorTime onScheduler:[RACScheduler mainThreadScheduler]] takeUntil:self.racSlideOB.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        if (!self.mpb.isSliderSelected) {
            CGFloat value = self.audioPlayer.currentTime/(float)self.audioPlayer.duration;
            self.mpb.slider.value = value;
        }
        CGFloat time = self.audioPlayer.currentTime;
        
        [self.mpb updateTimeCurrentFrameTime:time];
        self.mpb.timeCurrentL.text = [self stringFromTime5:time];
        
        // update 歌词页面
        NSString * timeText8 = [self stringFromTime8:time];
        // 显示歌词1: 实时的
        LrcDetailEntity * lyric = self.mpb.musicLyricDic[timeText8];
        if (lyric) {
            if (!self.mpb.isShowLrc) {
                self.mpb.songInfoL.text = lyric.lrcText;
            }
            NSDictionary * dic = @{@"lyric":lyric};
            [MGJRouter openURL:MUrl_updateLrcTime withUserInfo:dic completion:nil];
        }
    }];
}

- (void)updateIosLockInfo {
    AVAudioPlayer * ap            = self.audioPlayer;
    
    
    if (ap.duration > 0) {
        if (![self.audioPlayer.url.absoluteString isEqualToString:self.lastImageUrl]) {
            self.lastImageUrl = self.audioPlayer.url.absoluteString;
            
            // 播放进度 和 歌词信息, 一个循环只需要走一次
            CGFloat time = self.audioPlayer.duration;
            self.mpb.timeDurationL.text = [self stringFromTime5:time];
            
            self.mpb.currentItem.musicDuration = time;
            [self.mpb updateTimeDurationFrameTime:time];
            
            self.mpb.songInfoL.text = self.musicItem.fileNameDeleteExtension;
            // [NSString stringWithFormat:@"%@ - %@", self.musicItem.musicAuthor, self.musicItem.musicName];
            
            // 歌词和cover
            [self.mpb updateLyricKugou];
            
            // 系统控制器
            [self addIosPlayContoller];
        }
        
        self.mpb.slider.value       = self.audioPlayer.currentTime/self.audioPlayer.duration;
        self.mpb.timeCurrentL.text  = [self stringFromTime5:self.audioPlayer.currentTime];
        
    }else{
        MPNowPlayingInfoCenter * mpic = [MPNowPlayingInfoCenter defaultCenter];
        [mpic setNowPlayingInfo:nil];
    }
}

- (void)addIosPlayContoller {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        MPNowPlayingInfoCenter * mpic = [MPNowPlayingInfoCenter defaultCenter];
        UIImage * coverImage = [MusicPlayTool imageOfUrl:self.audioPlayer.url];
        
        if (coverImage) {
            CGSize size = CGSizeMake(self.mpb.coverBT.size.width*[UIScreen mainScreen].scale, self.mpb.coverBT.size.height*[UIScreen mainScreen].scale);
            [self.mpb.coverBT setImage:[UIImage imageFromImage:coverImage size:size] forState:UIControlStateNormal];
        } else {
            [self.mpb.coverBT setImage:self.defaultCoverImage forState:UIControlStateNormal];
        }
        
#if TARGET_OS_MACCATALYST
#else
        NSMutableDictionary *songInfo = [ [NSMutableDictionary alloc] init];
        
        MPMediaItemArtwork * media = [[MPMediaItemArtwork alloc] initWithImage:coverImage ? :self.defaultCoverImage];
        [songInfo setObject:media forKey:MPMediaItemPropertyArtwork];
        
        //锁屏标题
        [songInfo setObject:[NSNumber numberWithFloat:self.audioPlayer.duration] forKey:MPMediaItemPropertyPlaybackDuration];
        [songInfo setObject:[NSNumber numberWithFloat:self.audioPlayer.currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        
        [songInfo setObject:self.musicItem.musicName forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:self.musicItem.musicAuthor forKey:MPMediaItemPropertyArtist];
        //[songInfo setObject:author forKey:MPMediaItemPropertyAlbumTitle];
        [mpic setNowPlayingInfo:songInfo];
#endif
        
    });
}

- (NSString *)stringFromTime5:(CGFloat)time {
    return [NSDate clockText:time];
}

- (NSString *)stringFromTime8:(CGFloat)time {
    // floor 函数：“下取整”，或者说“向下舍入”，不大于 x 的最大整数
    // fmod 对某个数字求余
    NSInteger hour = floor(time / 3600);
    CGFloat minute = fmod(floor(time/60), 60.0f);
    CGFloat second = fmod(time, 60.0f);
    NSInteger secondInt = floor(second);
    
    if (hour < 0 || minute < 0 || second < 0) {
        return @"00:00.00";
    }
    
    if (LrcMonitor0_1S) {
        NSInteger secondPoint = (second - (int)second)*10;
        if (hour > 0) {
            return [NSString stringWithFormat:@"%02li:%02.0f:%02i.%01i0", hour, minute, (int)secondInt, (int)secondPoint];
        } else {
            return [NSString stringWithFormat:@"%02.0f:%02i.%01i0", minute, (int)secondInt, (int)secondPoint];
        }
    } else {
        NSInteger secondPoint = (second - (int)second)*100;
        if (hour > 0) {
            return [NSString stringWithFormat:@"%02li:%02.0f:%02i.%02i", hour, minute, (int)secondInt, (int)secondPoint];
        } else {
            return [NSString stringWithFormat:@"%02.0f:%02i.%02i", minute, (int)secondInt, (int)secondPoint];
        }
    }
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
    
    // 显示歌词2: 拖拽
    // NSLog(@"拖拽时间: %@", self.mpb.timeCurrentL.text);
    LrcDetailEntity * lyric = self.mpb.musicLyricDic[self.mpb.timeCurrentL.text];
    if (!lyric) {
        NSInteger time = [LrcTool timeFromText:self.mpb.timeCurrentL.text];
        for (NSInteger i = 0; i<self.mpb.musicLyricArray.count; i++) {
            LrcDetailEntity * entity = self.mpb.musicLyricArray[i];
            if (time < entity.time) {
                lyric = entity;
                break;
            }
        }
    }
    if (lyric) {
        if (!self.mpb.isShowLrc) {
            self.mpb.songInfoL.text = lyric.lrcText;
        }
        
        NSDictionary * dic = @{@"lyric":lyric};
        [MGJRouter openURL:MUrl_updateLrcTime withUserInfo:dic completion:nil];
    }
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

// https://stackoverflow.com/questions/24879939/how-to-add-artwork-in-audio-file-to-show-in-album-cover
+ (BOOL)editAudioFileUrl1:(NSURL * _Nullable)audioFileURL1
                inputUrl2:(NSURL * _Nullable)audioFileURL2
                   output:(NSURL * _Nonnull)audioFileOutput
                   artist:(NSString * _Nullable)artist         // 艺术家
                 songName:(NSString * _Nullable)songName       // 歌名
                    album:(NSString * _Nullable)album          // 专辑
                  artwork:(NSData   * _Nullable)artworkImageData // 封面
                 complete:(BlockPBool _Nullable)completeBlock
{
    if ((!audioFileURL1 && !audioFileURL2)|| !audioFileOutput) {
        return NO;
    }
    
    // 删除之前的文件
    [[NSFileManager defaultManager] removeItemAtURL:audioFileOutput error:NULL];
    
    //CMTime nextClipStartTime = kCMTimeZero;
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    if (audioFileURL1) {
        AVMutableCompositionTrack *compositionAudioTrack1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        CGFloat playbackDelayAfterTimeMix1 = 0;
        CMTime nextClipStartTimeMix1;
        if (playbackDelayAfterTimeMix1 > 0) {
            nextClipStartTimeMix1 = CMTimeMake(playbackDelayAfterTimeMix1, 1);
        }else{
            nextClipStartTimeMix1 = kCMTimeZero;
        }
        
        CGFloat playbackDelayMix1 = 0;
        CMTime startTimeMix1;
        if (playbackDelayMix1 > 0) {
            startTimeMix1 = CMTimeMake(playbackDelayMix1, 1);
        }else{
            startTimeMix1 = kCMTimeZero;
        }
        
        [compositionAudioTrack1 setPreferredVolume:1];
        
        NSURL *url1 = audioFileURL1; //[NSURL fileURLWithPath:soundOne];
        AVAsset *avAsset = [AVURLAsset URLAssetWithURL:url1 options:nil];
        NSArray *tracks = [avAsset tracksWithMediaType:AVMediaTypeAudio];
        AVAssetTrack *clipAudioTrack;
        if (tracks.count > 0) {
            clipAudioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        }else{
            return NO;
        }
        [compositionAudioTrack1 insertTimeRange:CMTimeRangeMake(startTimeMix1, avAsset.duration) ofTrack:clipAudioTrack atTime:nextClipStartTimeMix1 error:nil];
    }
    
    if (audioFileURL2) {
        //avAsset.commonMetadata
        AVMutableCompositionTrack *compositionAudioTrack2 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        CGFloat playbackDelayAfterTimeMix2 = 0;
        CMTime nextClipStartTimeMix2;
        if (playbackDelayAfterTimeMix2 > 0) {
            nextClipStartTimeMix2 = CMTimeMake(playbackDelayAfterTimeMix2, 1);
        }else{
            nextClipStartTimeMix2 = kCMTimeZero;
        }
        
        CGFloat playbackDelayMix2 = 0;
        CMTime startTimeMix2;
        if (playbackDelayMix2 > 0) {
            startTimeMix2 = CMTimeMake(playbackDelayMix2, 1);
        }else{
            startTimeMix2 = kCMTimeZero;
        }
        
        [compositionAudioTrack2 setPreferredVolume:1];
        //NSString *soundOne1  =[[NSBundle mainBundle]pathForResource:@"test" ofType:@"caf"];
        NSURL *url2 = audioFileURL2;  //[NSURL fileURLWithPath:soundOne1];
        AVAsset *avAsset1 = [AVURLAsset URLAssetWithURL:url2 options:nil];
        NSArray *tracks1 = [avAsset1 tracksWithMediaType:AVMediaTypeAudio];
        AVAssetTrack *clipAudioTrack1;
        if (tracks1.count > 0) {
            clipAudioTrack1 = [[avAsset1 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        }else{
            return NO;
        }
        [compositionAudioTrack2 insertTimeRange:CMTimeRangeMake(startTimeMix2, avAsset1.duration) ofTrack:clipAudioTrack1 atTime:nextClipStartTimeMix2 error:nil];
    }
    /**
     added MetadataItem
     **/
    NSMutableArray * metadataArray = [NSMutableArray new];
    
    if (artist.length > 0) { // 艺术家
        AVMutableMetadataItem *artistMetadata = [[AVMutableMetadataItem alloc] init];
        artistMetadata.key      = AVMetadataiTunesMetadataKeyArtist;
        artistMetadata.keySpace = AVMetadataKeySpaceiTunes;
        artistMetadata.locale   = [NSLocale currentLocale];
        artistMetadata.value    = artist;
        
        [metadataArray addObject:artistMetadata];
    }
    
    if (album.length > 0) { // 专辑
        AVMutableMetadataItem *albumMetadata = [[AVMutableMetadataItem alloc] init];
        albumMetadata.key      = AVMetadataiTunesMetadataKeyAlbum;
        albumMetadata.keySpace = AVMetadataKeySpaceiTunes;
        albumMetadata.locale   = [NSLocale currentLocale];
        albumMetadata.value    = album;
        
        [metadataArray addObject:albumMetadata];
    }
    
    if (songName.length > 0) { // 歌名
        AVMutableMetadataItem *songMetadata = [[AVMutableMetadataItem alloc] init];
        songMetadata.key = AVMetadataiTunesMetadataKeySongName;
        songMetadata.keySpace = AVMetadataKeySpaceiTunes;
        songMetadata.locale = [NSLocale currentLocale];
        songMetadata.value = songName;
        
        [metadataArray addObject:songMetadata];
    }
    
    if (artworkImageData.length > 0) { // 设置封面
        AVMutableMetadataItem *imageMetadata = [[AVMutableMetadataItem alloc] init];
        imageMetadata.key = AVMetadataiTunesMetadataKeyCoverArt;
        imageMetadata.keySpace = AVMetadataKeySpaceiTunes;
        imageMetadata.locale = [NSLocale currentLocale];
        imageMetadata.value = artworkImageData; //imageData is NSData of UIImage.
        
        [metadataArray addObject:imageMetadata];
    }
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    if (nil == exportSession) {
        return NO;
    }
    
    exportSession.metadata  = metadataArray;
    exportSession.outputURL = audioFileOutput;
    exportSession.outputFileType = AVFileTypeAppleM4A;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^ {
       
        switch (exportSession.status) {
            case AVAssetExportSessionStatusUnknown :{
                
                break;
            }
            case AVAssetExportSessionStatusWaiting :{
                
                break;
            }
            case AVAssetExportSessionStatusExporting :{
                
                break;
            }
            case AVAssetExportSessionStatusCompleted :{
                AlertToastTitle(@"设置完成");
                if (completeBlock) {
                    completeBlock(YES);
                }
                break;
            }
            case AVAssetExportSessionStatusFailed :
            case AVAssetExportSessionStatusCancelled :{ break;}
            default: {
                AlertToastTitle(([[exportSession error] localizedDescription]));
                if (completeBlock) {
                    completeBlock(NO);
                }
            }
        }
    }];
    
    return YES;
}

@end
