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

@property (nonatomic, strong) NSURL               * musicUrl;
@property (nonatomic, strong) AVAudioPlayer       * audioPlayer;
@property (nonatomic, weak  ) MusicPlayItemEntity * musicItem;

@property (nonatomic, strong) UIImage             * defaultCoverImage;

@property (nonatomic, copy  , nullable) BlockPVoid nextMusicBlock_SongListDetailVC;

+ (MusicPlayTool *)share;

- (void)playItem:(MusicPlayItemEntity *)item autoPlay:(BOOL)autoPlay;
- (void)playAtTimeScale:(float)scale;

- (void)pauseEvent;
- (void)rewindEvent:(int)second;
- (void)forwardEvent:(int)second;

+ (UIImage *)imageOfUrl:(NSURL *)url;

- (NSString *)stringFromTime:(int)time;

@end

NS_ASSUME_NONNULL_END
