//
//  LocalMusicVCPresenter.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import <Foundation/Foundation.h>
#import "LocalMusicVCProtocol.h"

// 处理和View事件
@interface LocalMusicVCPresenter : NSObject <LocalMusicVCEventHandler, LocalMusicVCDataSource, UITableViewDelegate, UITableViewDataSource>

- (void)setMyInteractor:(id)interactor;

- (void)setMyView:(id)view;

// 开始执行事件,比如获取网络数据
- (void)startEvent;

@end
