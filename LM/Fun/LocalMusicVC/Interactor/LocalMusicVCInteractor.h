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

@property (nonatomic, weak  ) NSMutableArray * infoArray;

- (void)initData;


@end
