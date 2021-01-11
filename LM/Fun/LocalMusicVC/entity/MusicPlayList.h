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

//
//@protocol  MusicPlayListEntity;
//@interface MusicPlayListEntity : PoporJsonModel
//
//@property (nonatomic, strong) NSString    * name;
//@property (nonatomic        ) MpViewOrder viewOrder;
//@property (nonatomic        ) NSInteger   recoredNum;//记录增加的个数
//
//@property (nonatomic, strong) NSMutableArray<FileEntity> * itemArray;
//
////- (void)sortArray:(MpViewOrder)viewOrder;
//
//@end
//
//
@protocol  MusicPlayList;
@interface MusicPlayList : PoporJsonModel

@property (nonatomic, strong) NSMutableArray<FileEntity> * songListArray;

@end

@interface MusicPlayListShare : NSObject
@property (nonatomic, strong) MusicPlayList * list;
@property (nonatomic, strong) NSMutableDictionary * allFileEntityDic;

+ (instancetype)share;

+ (NSString *)listFilePath;
- (void)updateSongList;

@end

NS_ASSUME_NONNULL_END
