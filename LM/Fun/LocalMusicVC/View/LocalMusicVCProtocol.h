//
//  LocalMusicVCProtocol.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "MusicPlayBar.h"

#import "LocalMusicHeadView.h"
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
@property (nonatomic, getter=isSearchTypeOld) BOOL searchTypeOld;// 显示搜索模式
@property (nonatomic, getter=isSearchType) BOOL searchType;// 显示搜索模式
@property (nonatomic, strong) NSMutableArray * searchArray;

@property (nonatomic, readonly, getter=isRoot) BOOL root;

// MARK: 外部注入的


@end

// MARK: 数据来源
@protocol LocalMusicVCDataSource <NSObject>

@end

// MARK: UI事件
@protocol LocalMusicVCEventHandler <NSObject>

- (void)searchAction:(UISearchBar *)bar;
- (void)reloadImageColor;
- (void)freshTVVisiableCellEvent;

@end
