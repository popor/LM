//
//  ListVCProtocol.h
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import <UIKit/UIKit.h>

// MARK: 对外接口
@protocol ListVCProtocol <NSObject>

- (UIViewController *)vc;
- (void)setMyPresent:(id)present;

// MARK: 自己的

// MARK: 外部注入的

@end

// MARK: 数据来源
@protocol ListVCDataSource <NSObject>

@end

// MARK: UI事件
@protocol ListVCEventHandler <NSObject>

@end
