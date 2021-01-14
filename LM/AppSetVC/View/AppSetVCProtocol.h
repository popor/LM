//
//  AppSetVCProtocol.h
//  LM
//
//  Created by popor on 2021/1/14.
//  Copyright © 2021 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "SwitchCell.h"

NS_ASSUME_NONNULL_BEGIN

// MARK: 对外接口
@protocol AppSetVCProtocol <NSObject>

- (UIViewController *)vc;

// MARK: 自己的
@property (nonatomic, strong) UITableView * infoTV;

@property (nonatomic, strong) UILabel * versionL;

// MARK: 外部注入的

@end

// MARK: 数据来源
@protocol AppSetVCDataSource <NSObject>

@end

// MARK: UI事件
@protocol AppSetVCEventHandler <NSObject>

@end

NS_ASSUME_NONNULL_END
