//
//  MusicPlayListTool.h
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MusicPlayList.h"

#define MpltShare [MusicPlayListTool share]

NS_ASSUME_NONNULL_BEGIN

@interface MusicPlayListTool : NSObject


+ (MusicPlayListTool *)share;

@property (nonatomic, strong) MusicPlayList * list;
@property (nonatomic, strong) NSMutableArray * currentTempList; // 针对本地歌单
@property (nonatomic, weak  ) NSMutableArray * currentWeakList; // 针对保存的歌单
@property (nonatomic, strong) NSString * docPath;
- (void)addListName:(NSString *)name;

- (void)update;

@end

NS_ASSUME_NONNULL_END
