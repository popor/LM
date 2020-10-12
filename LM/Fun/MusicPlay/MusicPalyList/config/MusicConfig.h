//
//  MusicConfig.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import <PoporJsonModel/PoporJsonModel.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int, McPlayOrder) {
    McPlayOrderNormal, // 普通
    McPlayOrderRandom, // 随机
    McPlayOrderSingle, // 单曲循环
};

typedef NS_ENUM(int, McPlayType) {
    McPlayType_songList,
    McPlayType_local,
    
    McPlayType_searchSongList,
    McPlayType_searchLocal,
};

#define McPlayOrderImageArray @[@"loop_order", @"loop_random", @"loop_single"]

@interface MusicConfig : PoporJsonModel

@property (nonatomic        ) McPlayOrder playOrder;  // 播放顺序, 随机还是顺序

@property (nonatomic        ) McPlayType playType;

// 歌单部分
@property (nonatomic        ) NSInteger songIndexList;// 歌单位置
@property (nonatomic        ) NSInteger songIndexItem;// 歌曲位置

// 本地部分
@property (nonatomic, copy  ) NSString * localFolderName;
@property (nonatomic, copy  ) NSString * localMusicName;

@end

NS_ASSUME_NONNULL_END
