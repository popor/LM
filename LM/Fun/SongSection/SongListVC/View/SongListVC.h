//
//  SongListVC.h
//  LM
//
//  Created by popor on 2020/9/20.
//  Copyright © 2020 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "SongListVCProtocol.h"

@interface SongListVC : UIViewController <SongListVCProtocol>

- (instancetype)initWithDic:(NSDictionary *)dic;

- (void)addViews;

// 开始执行事件,比如获取网络数据
- (void)startEvent;


@end
