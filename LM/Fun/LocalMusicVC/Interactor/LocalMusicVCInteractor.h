//
//  LocalMusicVCInteractor.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import <Foundation/Foundation.h>

#import "FileTool.h"
#import "MusicPlayListEntity.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * KRootCellFolderName_all = @".allFile.";

// 处理Entity事件
@interface LocalMusicVCInteractor : NSObject

@property (nonatomic, weak  ) MusicPlayListEntityShare * mplShare;

@property (nonatomic, weak  ) NSMutableArray<FileEntity> * localArray;  // 本地文件夹

// 初始化物理文件夹等
- (void)initData;

- (void)addListName:(NSString *)name;
- (void)updateSongList;
- (void)freshFavFolderEvent;

// 排序
- (void)sortFileEntityArray:(NSArray<FileEntity> *)fileEntityArray finish:(void (^ _Nonnull)(FileSortType sortType, NSArray * sortArray))block;

@end

NS_ASSUME_NONNULL_END
