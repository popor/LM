//
//  MusicPlayListTool.h
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MusicPlayList.h"
#import "MusicConfig.h"

NS_ASSUME_NONNULL_BEGIN

#define MpltShare [MusicPlayListTool share]

static NSString * RecordFolderName = @"record";
static NSString * MusicFolderName  = @"music";

@interface MusicPlayListTool : NSObject


+ (MusicPlayListTool *)share;

@property (nonatomic, strong) MusicPlayList * list;
@property (nonatomic, strong) MusicConfig   * config;
@property (nonatomic, strong) NSMutableArray * currentTempList; // 针对本地歌单
@property (nonatomic, weak  ) NSMutableArray * currentWeakList; // 针对保存的歌单

@property (nonatomic        ) BOOL lastPlayLocal; // 最后播放的是否是本地文件夹.
@property (nonatomic, copy  ) NSString * lastPlayLocalFolderName; // 最后播放文件夹名称
@property (nonatomic, copy  ) NSString * lastPlayLocalMusicName;  // 最后播放音乐名称

- (void)addListName:(NSString *)name;

- (void)updateList;
- (void)updateConfig;

@end

NS_ASSUME_NONNULL_END
