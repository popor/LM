//
//  MusicPlayEntity.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicPlayEntity : NSObject

@property (nonatomic, strong) NSURL * url;
@property (nonatomic, strong) NSString * author; // 作者
@property (nonatomic, strong) NSString * title;  // 歌名
@property (nonatomic        ) int duration;
@property (nonatomic, strong) NSString * listName; // 歌单名称
// @property (nonatomic        ) int index;


@end

NS_ASSUME_NONNULL_END
