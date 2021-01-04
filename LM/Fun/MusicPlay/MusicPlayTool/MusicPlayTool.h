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
@property (nonatomic, weak  ) FileEntity          * musicItem;

@property (nonatomic, strong) UIImage             * defaultCoverImage;

@property (nonatomic, copy  , nullable) BlockPVoid nextMusicBlock_SongListDetailVC;

+ (MusicPlayTool *)share;

- (void)playItem:(FileEntity *)item autoPlay:(BOOL)autoPlay;
- (void)playAtTimeScale:(float)scale;

- (void)pauseEvent;
- (void)rewindEvent:(int)second;
- (void)forwardEvent:(int)second;

+ (UIImage *)imageOfUrl:(NSURL *)url;

- (NSString *)stringFromTime5:(CGFloat)time;
- (NSString *)stringFromTime8:(CGFloat)time;

// 添加封面等信息
+ (BOOL)editAudioFileUrl1:(NSURL * _Nullable)audioFileURL1
                inputUrl2:(NSURL * _Nullable)audioFileURL2
                   output:(NSURL * _Nonnull)audioFileOutput
                   artist:(NSString * _Nullable)artist         // 艺术家
                 songName:(NSString * _Nullable)songName       // 歌名
                    album:(NSString * _Nullable)album          // 专辑
                  artwork:(NSData   * _Nullable)artworkImageData // 封面
                 complete:(BlockPBool _Nullable)completeBlock;
;

@end

NS_ASSUME_NONNULL_END
