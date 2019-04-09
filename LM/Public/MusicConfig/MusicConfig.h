//
//  MusicConfig.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int, McPlayOrder) {
    McPlayOrderNormal, // 普通
    McPlayOrderRandom, // 随机
    McPlayOrderSingle, // 单曲循环
};

#define McPlayOrderImageArray @[@"loop_order", @"loop_random", @"loop_single"]

@interface MusicConfig : NSObject

@property (nonatomic        ) NSInteger listIndex;// 歌单位置
@property (nonatomic        ) NSInteger itemIndex;// 歌曲位置
@property (nonatomic        ) McPlayOrder playOrder;

@end

NS_ASSUME_NONNULL_END
