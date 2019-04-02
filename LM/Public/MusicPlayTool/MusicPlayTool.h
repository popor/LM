//
//  MusicPlayer.h
//  LM
//
//  Created by apple on 2019/3/28.
//  Copyright © 2019 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

#define MptShare [MusicPlayTool share]

@interface MusicPlayTool : NSObject

@property (nonatomic, strong) NSURL * musicUrl;
@property (nonatomic, strong) AVAudioPlayer * audioPlayer;

+ (MusicPlayTool *)share;

- (void)playEvent:(NSURL *)url;
- (void)pauseEvent;
- (void)rewindEvent:(int)second;
- (void)forwardEvent:(int)second;

@end

NS_ASSUME_NONNULL_END
