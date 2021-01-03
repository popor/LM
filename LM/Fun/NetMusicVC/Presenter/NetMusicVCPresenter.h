//
//  NetMusicVCPresenter.h
//  LM
//
//  Created by 王凯庆 on 2021/1/3.
//  Copyright © 2021 popor. All rights reserved.

#import <Foundation/Foundation.h>
#import "NetMusicVCProtocol.h"

// 处理和View事件
@interface NetMusicVCPresenter : NSObject <NetMusicVCEventHandler, NetMusicVCDataSource>

- (void)setMyInteractor:(id)interactor;

- (void)setMyView:(id)view;

// 开始执行事件,比如获取网络数据
- (void)startEvent;

@end
