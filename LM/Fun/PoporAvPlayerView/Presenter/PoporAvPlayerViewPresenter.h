//
//  PoporAvPlayerViewPresenter.h
//  hywj
//
//  Created by popor on 2020/9/5.
//  Copyright © 2020 popor. All rights reserved.

#import <Foundation/Foundation.h>
#import "PoporAvPlayerViewProtocol.h"

// 处理和View事件
@interface PoporAvPlayerViewPresenter : NSObject <PoporAvPlayerViewEventHandler, PoporAvPlayerViewDataSource>

- (void)setMyInteractor:(id)interactor;

- (void)setMyView:(id)view;

// 开始执行事件,比如获取网络数据
- (void)startEvent;

@end
