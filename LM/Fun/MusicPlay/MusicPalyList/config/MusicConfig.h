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

#define McPlayOrderImageArray @[@"loop_order", @"loop_random", @"loop_single"]

@interface MusicConfig : PoporJsonModel

@property (nonatomic        ) McPlayOrder playOrder;  // 播放顺序, 随机还是顺序

// 歌单部分
@property (nonatomic        ) NSInteger songIndexList;// 歌单位置
@property (nonatomic        ) NSInteger songIndexItem;// 歌曲位置

// 本地部分
@property (nonatomic, copy  ) NSString * localFolderName;
@property (nonatomic, copy  ) NSString * localMusicName;

@property (nonatomic        ) NSInteger  currentPlayIndexRow; // 用于aimBT定位使用

@end

NS_ASSUME_NONNULL_END
