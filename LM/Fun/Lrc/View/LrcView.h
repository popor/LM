//
//  LrcView.h
//  LM
//
//  Created by popor on 2020/10/14.
//  Copyright © 2020 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "LrcViewProtocol.h"

@interface LrcView : UIView <LrcViewProtocol>

- (instancetype)initWithDic:(NSDictionary *)dic;

- (void)assembleViper;

- (void)addViews;

// 开始执行事件,比如获取网络数据
- (void)startEvent;


@end
