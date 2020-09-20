//
//  SongListVCProtocol.h
//  LM
//
//  Created by popor on 2020/9/20.
//  Copyright © 2020 popor. All rights reserved.

#import <UIKit/UIKit.h>

#import "SongListHeadView.h"

NS_ASSUME_NONNULL_BEGIN

// MARK: 对外接口
@protocol SongListVCProtocol <NSObject>

- (UIViewController *)vc;

// MARK: 自己的
@property (nonatomic, strong) UITableView * infoTV;

// MARK: 外部注入的

@end

// MARK: 数据来源
@protocol SongListVCDataSource <NSObject>

@end

// MARK: UI事件
@protocol SongListVCEventHandler <NSObject>

@end

NS_ASSUME_NONNULL_END
