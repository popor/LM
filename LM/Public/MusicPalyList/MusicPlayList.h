//
//  MusicPlayList.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FileEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface MusicPlayItemEntity : NSObject

@property (nonatomic, strong) NSString * docPath; // 在APP doc 下面的路径

@property (nonatomic, strong) NSString * fileName;// 文件名称
@property (nonatomic, strong) NSString * musicTitle;// 歌名
@property (nonatomic, strong) NSString * musicAuthor;// 作者

@property (nonatomic        ) int      duration;
@property (nonatomic, strong) NSString * listName;// 歌单名称
// @property (nonatomic        ) int index;
@property (nonatomic, getter=isAvailable) BOOL available; // 是否还存在

+ (MusicPlayItemEntity *)initWithFileEntity:(FileEntity *)fileEntity;

@end


@interface MusicPlayListEntity : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSMutableArray<MusicPlayItemEntity *> * array;

@end


@interface MusicPlayList : NSObject

@property (nonatomic, strong) NSMutableArray<MusicPlayListEntity *> * array;

@end

NS_ASSUME_NONNULL_END
