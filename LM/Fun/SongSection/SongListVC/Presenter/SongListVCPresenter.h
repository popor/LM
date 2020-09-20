//
//  SongListVCPresenter.h
//  LM
//
//  Created by popor on 2020/9/20.
//  Copyright © 2020 popor. All rights reserved.

#import <Foundation/Foundation.h>
#import "SongListVCProtocol.h"

// 处理和View事件
@interface SongListVCPresenter : NSObject <SongListVCEventHandler, SongListVCDataSource>

- (void)setMyInteractor:(id)interactor;

- (void)setMyView:(id)view;

// 开始执行事件,比如获取网络数据
- (void)startEvent;

@end
