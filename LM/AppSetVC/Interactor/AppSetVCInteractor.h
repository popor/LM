//
//  AppSetVCInteractor.h
//  LM
//
//  Created by popor on 2021/1/14.
//  Copyright © 2021 popor. All rights reserved.

#import <Foundation/Foundation.h>

#import "CellInfoEntity.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AppSetCellType) {
    AppSetCellType_启动自动播放 = 1,
    AppSetCellType_首页显示设置,
    AppSetCellType_自动关闭歌单列表窗口,
    AppSetCellType_删除歌单列表的文件,
    AppSetCellType_删除文件夹的文件,
};


// 处理Entity事件
@interface AppSetVCInteractor : NSObject

@property (nonatomic, strong) NSMutableArray * cellCieArray;

@end

NS_ASSUME_NONNULL_END
