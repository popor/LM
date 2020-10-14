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
- (void)updateInfoTVContentInset;

// MARK: 自己的
@property (nonatomic, strong) UITableView * infoTV;
@property (nonatomic, strong) UIButton    * closeBT;
@property (nonatomic, getter=isShow) BOOL   show;

@property (nonatomic, strong) UILabel  * timeL;
@property (nonatomic, strong) UIButton * playBT;

// MARK: 外部注入的

@end

// MARK: 数据来源
@protocol LrcViewDataSource <NSObject>

@end

// MARK: UI事件
@protocol LrcViewEventHandler <NSObject>

- (void)updateLrcArray:(NSArray *)array;
- (void)scrollToLrc:(LrcDetailEntity *)lrc;

@end

NS_ASSUME_NONNULL_END
