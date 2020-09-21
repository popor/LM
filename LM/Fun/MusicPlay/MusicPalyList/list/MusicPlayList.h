//
//  MusicPlayList.h
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


@protocol  MusicPlayItemEntity;
@interface MusicPlayItemEntity : PoporJsonModel

@property (nonatomic, strong) NSString * filePath;
@property (nonatomic, strong) NSString * fileName;
@property (nonatomic, strong) NSString * musicTitle;
@property (nonatomic, strong) NSString * musicAuthor;

@property (nonatomic, strong) UIImage  * musicCover;
@property (nonatomic        ) NSInteger index;

@property (nonatomic, getter=isAvailable) BOOL available; // 是否还存在

+ (MusicPlayItemEntity *)initWithFileEntity:(FileEntity *)fileEntity;

- (UIImage *)coverImage;

@end

@protocol  MusicPlayListEntity;
@interface MusicPlayListEntity : PoporJsonModel

@property (nonatomic, strong) NSString    * name;
@property (nonatomic        ) MpViewOrder viewOrder;
@property (nonatomic        ) NSInteger   recoredNum;//记录增加的个数

@property (nonatomic, strong) NSMutableArray<MusicPlayItemEntity> * itemArray;

- (void)sortArray:(MpViewOrder)viewOrder;

@end


@protocol  MusicPlayList;
@interface MusicPlayList : PoporJsonModel

@property (nonatomic, strong) NSMutableArray<MusicPlayListEntity> * songListArray;

@property (nonatomic        ) BOOL lastPlayLocal; // 最后播放的是否是本地文件夹.
@property (nonatomic, copy  ) NSString * lastPlayLocalFolderName; // 最后播放文件夹名称
@property (nonatomic, copy  ) NSString * lastPlayLocalMusicName;  // 最后播放音乐名称


@end

NS_ASSUME_NONNULL_END
