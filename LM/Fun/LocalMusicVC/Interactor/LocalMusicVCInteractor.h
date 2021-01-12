//
//  LocalMusicVCInteractor.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import <Foundation/Foundation.h>

#import "FileTool.h"
#import "MusicPlayList.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * KRootCellFolderName_all = @".allFile.";

// 处理Entity事件
@interface LocalMusicVCInteractor : NSObject

@property (nonatomic, weak  ) MusicPlayListShare * mplShare;

@property (nonatomic, strong) NSMutableArray<FileEntity> * recordArray; // 收藏文件夹
@property (nonatomic, weak  ) NSMutableArray<FileEntity> * localArray;  // 本地文件夹

@property (nonatomic, strong) FileEntity * _Nullable allFileEntity; // 全部音乐文件.

- (void)initData;

- (void)addListName:(NSString *)name;
- (void)updateSongList;
- (void)freshFavFolderEvent;

@end

NS_ASSUME_NONNULL_END
