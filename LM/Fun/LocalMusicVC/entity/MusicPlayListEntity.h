//
//  MusicPlayListEntity.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import <PoporJsonModel/PoporJsonModel.h>

#import "FileEntity.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int, MpViewOrder) {
    MpViewOrderAuthorAscend,
    MpViewOrderAuthorDescend,
    MpViewOrderTitleAscend,
    MpViewOrderTitleDescend,
    MpViewOrderCustomAscend,
    MpViewOrderCustomDescend,
};

#define MpViewOrderTitleArray    @[@"歌手名称: 正序", @"歌手名称: 倒序", @"歌曲名称: 正序", @"歌曲名称: 倒序", @"自定义: 正序", @"自定义: 倒序"]

@protocol  MusicPlayListEntity;
@interface MusicPlayListEntity : PoporJsonModel

@property (nonatomic, strong) NSMutableArray<FileEntity> * songListArray;

@end

@interface MusicPlayListEntityShare : NSObject

@property (nonatomic, strong) NSMutableDictionary * allFileEntityDic;
@property (nonatomic, strong) FileEntity * _Nullable allFileEntity; // 全部音乐文件.

// 歌曲列表
/*
 songListArray 包括全部和list.
 */
@property (nonatomic, strong) NSMutableArray<FileEntity> * songListArray;

@property (nonatomic, strong) MusicPlayListEntity * songFavListEntity;

// 歌曲文件夹
@property (nonatomic, strong) NSMutableArray<FileEntity> * songFolderArray;


@property (nonatomic, weak  ) NSMutableArray * currentWeakList; // 针对保存的歌单
@property (nonatomic, strong) NSMutableArray<FileEntity> * currentTempList; // 针对本地歌单

+ (instancetype)share;

+ (NSString *)listFilePath;
- (void)updateSongList;

@end

NS_ASSUME_NONNULL_END
