//
//  AppSetVCPresenter.h
//  LM
//
//  Created by popor on 2021/1/14.
//  Copyright © 2021 popor. All rights reserved.

#import <Foundation/Foundation.h>
#import "AppSetVCProtocol.h"

// 处理和View事件
@interface AppSetVCPresenter : NSObject <AppSetVCEventHandler, AppSetVCDataSource
, UITableViewDelegate, UITableViewDataSource
>

- (void)setMyInteractor:(id)interactor;

- (void)setMyView:(id)view;

// 开始执行事件,比如获取网络数据
- (void)startEvent;

@end
