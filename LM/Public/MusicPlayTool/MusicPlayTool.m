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
#import <KVOController/KVOController.h>

static int TimeHourOne = 3600;  // 1小时
static int TimeHourTen = 36000; // 10小时

@interface MusicPlayTool() <AVAudioPlayerDelegate>

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
        [session setActive:YES error:nil];
        
        [instance initIosController];
        [instance initFormater];
       
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            instance.mpb = MpbShare;
        });
        
    });
    return instance;
}

- (void)playItem:(MusicPlayItemEntity *)item autoPlay:(BOOL)autoPlay {
    NSString * path = [NSString stringWithFormat:@"%@/%@", MpltShare.docPath, item.filePath];
    NSURL * url     = [NSURL fileURLWithPath:path];
    self.musicTitle = item.fileName;
    
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
    self.racSlideOB = [MusicConfig new];
    
    @weakify(self);
    [[[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] takeUntil:self.racSlideOB.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        if (!self.mpb.isSliderSelected) {
            self.mpb.slider.value = self.audioPlayer.currentTime/(float)self.audioPlayer.duration;
        }
        // NSLog(@"slider.value:%f", self.mpb.slider.value);
        self.mpb.timeCurrentL.text = [self stringFromTime:self.audioPlayer.currentTime];
    }];
}

- (void)updateIosLockInfo {
    NSString * itemTitle          = self.musicTitle.toUtf8Encode;
    AVAudioPlayer * ap            = self.audioPlayer;
    MPNowPlayingInfoCenter * mpic = [MPNowPlayingInfoCenter defaultCenter];
    
    if (ap.duration > 0) {
        NSMutableDictionary *songInfo = [ [NSMutableDictionary alloc] init];
        //锁屏图片
        //    UIImage *img = [UIImage imageNamed:@"logo152"];
        //    if (img) {
        //        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc]initWithImage:img];
        //        [songInfo setObject: albumArt forKey:MPMediaItemPropertyArtwork ];
        //    }
        {
            UIImage * coverImage;
            // 设置封面
            AVURLAsset *avURLAsset = [[AVURLAsset alloc] initWithURL:self.audioPlayer.url options:nil];
            for (NSString * format in [avURLAsset availableMetadataFormats]){
                for (AVMetadataItem *metadata in [avURLAsset metadataForFormat:format]){
                    // NSLog(@"metadata.commonKey: %@", metadata.commonKey);
                    // if([metadata.commonKey isEqualToString:@"title"]){
                    //     NSString *title = (NSString *)metadata.value;//提取歌曲名
                    // }
                    if([metadata.commonKey isEqualToString:@"artwork"]){
                        NSData*data = [metadata.value copyWithZone:nil];
                        coverImage = [UIImage imageWithData:data];
                        MPMediaItemArtwork *media = [[MPMediaItemArtwork alloc] initWithImage:coverImage];
                        [songInfo setObject:media forKey:MPMediaItemPropertyArtwork];
                    }//还可以提取其他所需的信息
                }
            }
            if (coverImage) {
                self.mpb.coverIV.image = [UIImage imageFromImage:coverImage size:CGSizeMake(self.mpb.coverIV.size.width*[UIScreen mainScreen].scale, self.mpb.coverIV.size.height*[UIScreen mainScreen].scale)];
            }else{
                self.mpb.coverIV.image = [UIImage imageNamed:@"music_placeholder"];
            }
            coverImage = nil;
        }
        //锁屏标题
        NSString * name = itemTitle;
        if (name.pathExtension.length > 0) {
            name = [name substringToIndex:name.length - name.pathExtension.length - 1];
        }
        
        NSString * title = name;
        NSString * author = @"";
        NSRange range = [title rangeOfString:@"-"];
        if (range.length>0 && range.location>0) {
            author = [title substringToIndex:range.location];
            title  = [title substringFromIndex:range.location + range.length];
            title  = [title replaceWithREG:@"^\\s+" newString:@""];
        }
        
        [songInfo setObject:[NSNumber numberWithFloat:self.audioPlayer.duration] forKey:MPMediaItemPropertyPlaybackDuration];
        [songInfo setObject:[NSNumber numberWithFloat:self.audioPlayer.currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        
        [songInfo setObject:title forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:author forKey:MPMediaItemPropertyArtist];
        //[songInfo setObject:author forKey:MPMediaItemPropertyAlbumTitle];
        [mpic setNowPlayingInfo:songInfo];

        self.mpb.slider.value = self.audioPlayer.currentTime/self.audioPlayer.duration;
        self.mpb.timeCurrentL.text  = [self stringFromTime:self.audioPlayer.currentTime];
        
        self.mpb.timeDurationL.text = [self stringFromTime:self.audioPlayer.duration];
        self.mpb.nameL.text = name;
        
    }else{
        [mpic setNowPlayingInfo:nil];
    }
}

- (NSString *)stringFromTime:(int)time {
    NSDate * date = [NSDate dateFromUnixDate:time];
    if (time < TimeHourOne) {
        return [self.dateFormatterMS stringFromDate:date];
    }else if (time < TimeHourTen){
        return [self.dateFormatter1HMS stringFromDate:date];
    }else{
        return [self.dateFormatter10HMS stringFromDate:date];
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
    if (self.mpb.mplt.config.order == MusicConfigOrderSingle) {
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

@end
