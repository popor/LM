//
//  MusicPlayer.h
//  LM
//
//  Created by apple on 2019/3/28.
//  Copyright © 2019 popor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicPlayListTool.h"

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

#define MptShare [MusicPlayTool share]

@interface MusicPlayTool : NSObject

@property (nonatomic, strong) NSURL * musicUrl;
@property (nonatomic, strong, nullable) AVAudioPlayer * audioPlayer;
@property (nonatomic, strong) NSString * musicTitle;

+ (MusicPlayTool *)share;

- (void)playItem:(MusicPlayItemEntity *)item autoPlay:(BOOL)autoPlay;
- (void)playAtTimeScale:(float)scale;

- (void)pauseEvent;
- (void)rewindEvent:(int)second;
- (void)forwardEvent:(int)second;

@end

NS_ASSUME_NONNULL_END
