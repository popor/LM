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

static NSString * ConfigFolderName = @"config";
static NSString * MusicFolderName  = @"music";

@interface MusicPlayListTool : NSObject


+ (MusicPlayListTool *)share;

@property (nonatomic, strong) MusicPlayList * list;
@property (nonatomic, strong) MusicConfig   * config;
@property (nonatomic, strong) NSMutableArray * currentTempList; // 针对本地歌单
@property (nonatomic, weak  ) NSMutableArray * currentWeakList; // 针对保存的歌单

- (void)addListName:(NSString *)name;

- (void)updateSongList;

@end

NS_ASSUME_NONNULL_END
