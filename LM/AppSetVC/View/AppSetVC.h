//
//  AppSetVC.h
//  LM
//
//  Created by popor on 2021/1/14.
//  Copyright © 2021 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "AppSetVCProtocol.h"

@interface AppSetVC : UIViewController <AppSetVCProtocol>

- (instancetype)initWithDic:(NSDictionary *)dic;

- (void)addViews;

// 开始执行事件,比如获取网络数据
- (void)startEvent;


@end
