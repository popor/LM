//
//  RootVCProtocol.h
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import <UIKit/UIKit.h>

#import <PoporPopNormalNC/PoporPopNormalNC.h>
#import <PoporAlertBubbleView/AlertBubbleView.h>

#import "MusicPlayBar.h"

#define RootMoreArray       @[@"新增歌单", @"Wifi添加歌曲", @"查看本地歌曲", @"编辑歌单", @"检查更新"]
#define RootMoreCheckUpdate 4
#define RootMoreTvCellH     44

// MARK: 对外接口
@protocol RootVCProtocol <NSObject>

- (UIViewController *)vc;
- (void)setMyPresent:(id)present;

// MARK: 自己的
@property (nonatomic, weak  ) MusicPlayBar    * playbar;
@property (nonatomic, strong) UITableView     * infoTV;

@property (nonatomic, strong) AlertBubbleView * alertBubbleView;
@property (nonatomic, strong) UITableView     * alertBubbleTV;
@property (nonatomic, strong) UIColor         * alertBubbleTVColor;


// MARK: 外部注入的

@end

// MARK: 数据来源
@protocol RootVCDataSource <NSObject>

@end

// MARK: UI事件
@protocol RootVCEventHandler <NSObject>

- (void)showTVAlertAction:(UIBarButtonItem *)sender event:(UIEvent *)event;
- (void)showWifiVC;

@end
