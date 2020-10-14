//
//  LrcViewProtocol.h
//  LM
//
//  Created by popor on 2020/10/14.
//  Copyright © 2020 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "LrcDetailEntity.h"


NS_ASSUME_NONNULL_BEGIN

// MARK: 对外接口
@protocol LrcViewProtocol <NSObject>

- (UIView *)view;

// MARK: 自己的
@property (nonatomic, strong) UITableView * infoTV;
@property (nonatomic, strong) UIButton    * closeBT;
@property (nonatomic, getter=isShow) BOOL   show;

// MARK: 外部注入的
@property (nonatomic, copy  ) NSArray * lrcArray;

@end

// MARK: 数据来源
@protocol LrcViewDataSource <NSObject>

@end

// MARK: UI事件
@protocol LrcViewEventHandler <NSObject>

@end

NS_ASSUME_NONNULL_END
