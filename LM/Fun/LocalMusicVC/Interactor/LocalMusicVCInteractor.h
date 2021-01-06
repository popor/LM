//
//  LocalMusicVCInteractor.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import <Foundation/Foundation.h>

#import "FileTool.h"

// 处理Entity事件
@interface LocalMusicVCInteractor : NSObject

@property (nonatomic, strong) NSMutableArray<FileEntity> * allArray;    // 全部文件夹

@property (nonatomic, strong) NSMutableArray<FileEntity> * recordArray; // 收藏文件夹
@property (nonatomic, weak  ) NSMutableArray<FileEntity> * localArray;  // 本地文件夹

@property (nonatomic, strong) FileEntity * allFileEntity; // 全部音乐文件.



- (void)initData;


@end
