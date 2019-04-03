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
        
    });
    return instance;
}

- (void)playItem:(MusicPlayItemEntity *)item {
    NSString * path = [NSString stringWithFormat:@"%@/%@", MpltShare.docPath, item.filePath];
    NSURL * url     = [NSURL fileURLWithPath:path];
    self.musicTitle = item.fileName;
    
    if (self.audioPlayer && [self.audioPlayer.url isEqual:url]) {
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
    }else{
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        self.audioPlayer.delegate = self;
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
    }
    
    [self updateIosLockInfoTimeOffset:0];
}

- (void)updateIosLockInfoTimeOffset:(float)timeOffset {
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
                        UIImage *coverImage = [UIImage imageWithData:data];
                        MPMediaItemArtwork *media = [[MPMediaItemArtwork alloc] initWithImage:coverImage];
                        [songInfo setObject:media forKey:MPMediaItemPropertyArtwork];
                    }//还可以提取其他所需的信息
                }
            }
        }
        //锁屏标题
        NSString * title = itemTitle;
        NSString * author = @"";
        NSRange range = [title rangeOfString:@"-"];
        if (range.length>0 && range.location>0) {
            author = [title substringToIndex:range.location];
            title  = [title substringFromIndex:range.location + range.length];
        }
        if (ap.url.pathExtension.length > 0) {
            title = [title substringToIndex:title.length - ap.url.pathExtension.length - 1];
        }
        
        [songInfo setObject:[NSNumber numberWithFloat:self.audioPlayer.duration] forKey:MPMediaItemPropertyPlaybackDuration];
        [songInfo setObject:[NSNumber numberWithFloat:self.audioPlayer.currentTime + timeOffset] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        
        [songInfo setObject:title forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:author forKey:MPMediaItemPropertyArtist];
        //[songInfo setObject:author forKey:MPMediaItemPropertyAlbumTitle];
        [mpic setNowPlayingInfo:songInfo];
    }else{
        [mpic setNowPlayingInfo:nil];
    }
}

- (void)initIosController  {
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    // https://github.com/wsl2ls/LyricsAnalysis demo
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
    
    // 处理锁屏拖拽进度条事件
    @weakify(self);
    [commandCenter.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        @strongify(self);
        MPChangePlaybackPositionCommandEvent * playbackPositionEvent = (MPChangePlaybackPositionCommandEvent *)event;
        self.audioPlayer.currentTime = playbackPositionEvent.positionTime;
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
}

- (void)pauseEvent {
    // 暂停的时候刷新锁屏信息,但是这会造成信息闪烁跳动,酷狗没有做这个刷新.
    [self updateIosLockInfoTimeOffset:0.3];
    [self.audioPlayer pause];
}

- (void)rewindEvent:(int)second {
    
}

- (void)forwardEvent:(int)second {
    
}

#pragma mark - delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    [MpbShare nextBTEvent];
}

@end
