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
        
    });
    return instance;
}

- (void)playEvent:(NSURL *)url {
    if (self.audioPlayer && [self.audioPlayer.url isEqual:url]) {
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
    }else{
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        self.audioPlayer.delegate = self;
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
    }
}

- (void)playItem:(MusicPlayItemEntity *)item {
    NSString * path = [NSString stringWithFormat:@"%@/%@", MpltShare.docPath, item.docPath];
    NSURL * url     = [NSURL fileURLWithPath:path];
    
    if (self.audioPlayer && [self.audioPlayer.url isEqual:url]) {
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
    }else{
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
    }
    
    NSMutableDictionary *songInfo = [ [NSMutableDictionary alloc] init];
    //锁屏图片
    //    UIImage *img = [UIImage imageNamed:@"logo152"];
    //    if (img) {
    //        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc]initWithImage:img];
    //        [songInfo setObject: albumArt forKey:MPMediaItemPropertyArtwork ];
    //    }
    
    //锁屏标题
    NSString * title = item.title.toUtf8Encode;
    NSString * author = @"";
    NSRange range = [title rangeOfString:@"-"];
    if (range.length>0 && range.location>0) {
        author = [title substringToIndex:range.location];
        title  = [title substringFromIndex:range.location + range.length];
    }
    if (url.pathExtension.length > 0) {
        title = [title substringToIndex:title.length - url.pathExtension.length - 1];
    }
    //title = @"123";
    //title.toUtf8Encode
    [songInfo setObject:[NSNumber numberWithFloat:100] forKey:MPMediaItemPropertyPlaybackDuration];
    [songInfo setObject:title forKey:MPMediaItemPropertyTitle];
    [songInfo setObject:author forKey:MPMediaItemPropertyAlbumTitle];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo ];
    
    
}

- (void)pauseEvent {
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
