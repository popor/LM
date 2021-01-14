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

// 播放顺序, 随机还是顺序
@property (nonatomic        ) McPlayOrder playOrder;

@property (nonatomic        ) BOOL autoPlay;

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

@property (nonatomic, strong) MusicConfig   * config;

@end

NS_ASSUME_NONNULL_END
