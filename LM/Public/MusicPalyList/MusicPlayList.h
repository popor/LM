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

typedef NS_ENUM(int, MpViewOrder) {
    MpViewOrderAuthorAscend,
    MpViewOrderAuthorDescend,
    MpViewOrderTitleAscend,
    MpViewOrderTitleDescend,
    MpViewOrderCustomAscend,
    MpViewOrderCustomDescend,
};

#define MpViewOrderTitleArray    @[@"歌手名称: 正序", @"歌手名称: 倒序", @"歌曲名称: 正序", @"歌曲名称: 倒序", @"自定义: 正序", @"自定义: 倒序"]


@interface MusicPlayItemEntity : NSObject

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


@interface MusicPlayListEntity : NSObject

@property (nonatomic, strong) NSString    * name;
@property (nonatomic        ) MpViewOrder viewOrder;
@property (nonatomic        ) NSInteger   recoredNum;//记录增加的个数

@property (nonatomic, strong) NSMutableArray<MusicPlayItemEntity *> * array;

- (void)sortArray:(MpViewOrder)viewOrder;
//- (void)sortCustomAscending:(BOOL)Ascending;
//- (void)sortAuthorAscending:(BOOL)Ascending;
//- (void)sortTitleAscending:(BOOL)Ascending;

@end


@interface MusicPlayList : NSObject

@property (nonatomic, strong) NSMutableArray<MusicPlayListEntity *> * array;

@end

NS_ASSUME_NONNULL_END
