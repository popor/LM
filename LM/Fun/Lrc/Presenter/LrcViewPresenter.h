//
//  LrcViewPresenter.h
//  LM
//
//  Created by popor on 2020/10/14.
//  Copyright © 2020 popor. All rights reserved.

#import <Foundation/Foundation.h>
#import "LrcViewProtocol.h"

// 处理和View事件
@interface LrcViewPresenter : NSObject <LrcViewEventHandler, LrcViewDataSource, UITableViewDelegate, UITableViewDataSource>

- (void)setMyInteractor:(id)interactor;

- (void)setMyView:(id)view;

// 开始执行事件,比如获取网络数据
- (void)startEvent;

@end
