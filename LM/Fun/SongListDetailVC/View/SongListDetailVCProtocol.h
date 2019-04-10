//
//  SongListDetailVCProtocol.h
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "MusicPlayBar.h"
#import "MusicPlayListTool.h"
#import <PoporAlertBubbleView/AlertBubbleView.h>

#define SongListDetailVCSortTvCellH	44

// MARK: 对外接口
@protocol SongListDetailVCProtocol <NSObject>

- (UIViewController *)vc;
- (void)setMyPresent:(id)present;

// MARK: 自己的
@property (nonatomic, strong) UITableView     * infoTV;

@property (nonatomic, strong) AlertBubbleView * alertBubbleView;
@property (nonatomic, strong) UITableView     * alertBubbleTV;
@property (nonatomic, strong) UIColor         * alertBubbleTVColor;

@property (nonatomic, weak  ) MusicPlayBar    * playbar;
@property (nonatomic, strong) UIButton        * aimBT;
@property (nonatomic        ) BOOL            needUpdateSuperVC;

// MARK: 外部注入的
@property (nonatomic, weak  ) MusicPlayListEntity * listEntity;
@property (nonatomic, copy  ) BlockPBool      deallocBlock;

@end

// MARK: 数据来源
@protocol SongListDetailVCDataSource <NSObject>

@end

// MARK: UI事件
@protocol SongListDetailVCEventHandler <NSObject>

- (void)showSortTVAlertAction:(UIBarButtonItem *)sender event:(UIEvent *)event;
- (void)editCustomAscendAction;

- (void)defaultNcRightItem;

- (void)freshTVVisiableCellEvent;
- (void)aimAtCurrentItem:(UIButton *)bt;

@end
