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
    McPlayOrderRandom, // 随机
    McPlayOrderNormal, // 普通
    McPlayOrderSingle, // 单曲循环
};

#define McPlayOrderImageArray @[@"loop_random", @"loop_order", @"loop_single"]

@interface MusicConfig : PoporJsonModel

// 播放顺序, 随机还是顺序
@property (nonatomic        ) McPlayOrder playOrder; // 默认为 McPlayOrderRandom

@property (nonatomic        ) BOOL autoPlay;
@property (nonatomic        ) BOOL rootVcShowSetBt;
@property (nonatomic        ) BOOL autoCloseFavTV;  // 添加收藏歌单之后, 是否关闭歌单列表

@property (nonatomic        ) BOOL alertDeleteFile_virtualFolder;  // 删除歌单内部文件, 是否提示. 默认NO.
@property (nonatomic        ) BOOL alertDeleteFile_folder; // 删除歌单文件, 是否提示, 默认YES.

// 用于恢复之前的播放记录
@property (nonatomic, copy  ) NSString * playFileID;
@property (nonatomic, copy  ) NSString * playSearchKey;
@property (nonatomic, copy  ) NSString * playFilePath;
@property (nonatomic, copy  ) NSString * playFileNameDeleteExtension;

// 用于aimBT定位使用
@property (nonatomic        ) NSInteger  currentPlayIndexRow;

@end

@interface MusicConfigShare : NSObject

+ (instancetype)share;

@property (nonatomic, strong) MusicConfig * config;

@end

NS_ASSUME_NONNULL_END
