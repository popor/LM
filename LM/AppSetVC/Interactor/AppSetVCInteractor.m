//
//  AppSetVCInteractor.m
//  LM
//
//  Created by popor on 2021/1/14.
//  Copyright © 2021 popor. All rights reserved.

#import "AppSetVCInteractor.h"

@interface AppSetVCInteractor ()

@end

@implementation AppSetVCInteractor

- (id)init {
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

#pragma mark - VCDataSource
- (void)initData {
    self.cellCieArray = [NSMutableArray new];
    
    self.cellCieArray
    .add(CIE_TT(AppSetCellType_启动自动播放, @"APP启动时自动播放"))
    .add(CIE_TT(AppSetCellType_首页显示设置, @"首页显示设置"))
    .add(CIE_TT(AppSetCellType_自动关闭歌单列表窗口, @"自动关闭歌单列表窗口"))
    
    .add(CIE_TT(AppSetCellType_删除歌单列表的文件, @"提醒: 删除歌单列表的文件"))
    .add(CIE_TT(AppSetCellType_删除文件夹的文件,   @"提醒: 删除文件夹的文件"))
    
    
    ;
    
    
}

@end
