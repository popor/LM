//
//  NetMusicVC.h
//  LM
//
//  Created by 王凯庆 on 2021/1/3.
//  Copyright © 2021 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "NetMusicVCProtocol.h"

@interface NetMusicVC : UIViewController <NetMusicVCProtocol>

- (instancetype)initWithDic:(NSDictionary *)dic;

- (void)addViews;

// 开始执行事件,比如获取网络数据
- (void)startEvent;


@end
