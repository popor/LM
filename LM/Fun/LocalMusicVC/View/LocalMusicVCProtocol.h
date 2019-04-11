//
//  LocalMusicVCProtocol.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "MusicPlayBar.h"

#import <PoporAlertBubbleView/AlertBubbleView.h>
// MARK: 对外接口
@protocol LocalMusicVCProtocol <NSObject>

- (UIViewController *)vc;
- (void)setMyPresent:(id)present;

// MARK: 自己的
@property (nonatomic, weak  ) MusicPlayBar    * playbar;
@property (nonatomic, strong) UITableView     * infoTV;
@property (nonatomic, strong) UITableView     * musicListTV;
@property (nonatomic, weak  ) NSMutableArray  * itemArray;

@property (nonatomic, strong) UISearchBar     * searchBar;
@property (nonatomic, strong) UIView          * searchCoverView;

// MARK: 外部注入的
@property (nonatomic, copy  ) BlockPVoid   deallocBlock;

@end

// MARK: 数据来源
@protocol LocalMusicVCDataSource <NSObject>

@end

// MARK: UI事件
@protocol LocalMusicVCEventHandler <NSObject>

@end
