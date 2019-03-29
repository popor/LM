//
//  MusicPlayTool.m
//  LM
//
//  Created by apple on 2019/3/28.
//  Copyright © 2019 popor. All rights reserved.
//

#import "MusicPlayTool.h"

@implementation MusicPlayTool

+ (MusicPlayTool *)share {
    static dispatch_once_t once;
    static MusicPlayTool * instance;
    dispatch_once(&once, ^{
        instance = [self new];
        //instance.player = [[STKAudioPlayer alloc] init];
    });
    return instance;
}

- (void)playEvent:(NSURL *)url {
    if (self.audioPlayer && [self.audioPlayer.url isEqual:url]) {
        [self.audioPlayer play];
    }else{
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        // [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
    }
}

- (void)pauseEvent {
    [self.audioPlayer pause];
}

- (void)rewindEvent:(int)second {
    
}

- (void)forwardEvent:(int)second {
    
}

@end
