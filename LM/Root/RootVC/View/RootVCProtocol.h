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
#import <PoporSegmentView/PoporSegmentView.h>
#import <PoporMasonry/PoporMasonry.h>
#import "SongListVC.h"
#import "LocalMusicVC.h"

#define RootMoreArray       @[@"新增歌单", @"Wifi添加歌曲", @"编辑歌单", @"检查更新"]
#define RootMoreCheckUpdate 4
#define RootMoreTvCellH     44

// MARK: 对外接口
@protocol RootVCProtocol <NSObject>

- (UIViewController *)vc;

// MARK: 自己的
@property (nonatomic, weak  ) MusicPlayBar    * playbar;
@property (nonatomic, copy  ) NSArray         * titleArray;
@property (nonatomic, strong) NSMutableArray  * tvArray;

@property (nonatomic, strong) PoporSegmentView * segmentView;
@property (nonatomic, strong) UIScrollView    * tvSV;
@property (nonatomic, strong) SongListVC      * songListVC;
@property (nonatomic, strong) LocalMusicVC    * localMusicVC;

// MARK: 外部注入的

@end

// MARK: 数据来源
@protocol RootVCDataSource <NSObject>

@end

// MARK: UI事件
@protocol RootVCEventHandler <NSObject>

- (void)showWifiVC;

@end
