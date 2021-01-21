//
//  VideoPlayVC.h
//  hywj
//
//  Created by popor on 2020/12/15.
//  Copyright © 2020 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "VideoPlayVCProtocol.h"

@interface VideoPlayVC : UIViewController <VideoPlayVCProtocol>

- (instancetype)initWithDic:(NSDictionary *)dic;

- (void)addViews;

// 开始执行事件,比如获取网络数据
- (void)startEvent;


@end
