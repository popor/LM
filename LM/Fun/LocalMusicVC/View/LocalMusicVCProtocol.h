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
#import "FeedbackGeneratorTool.h"

NS_ASSUME_NONNULL_BEGIN

// MARK: 对外接口
@protocol LocalMusicVCProtocol <NSObject>

- (UIViewController *)vc;
- (void)setMyPresent:(id)present;

// MARK: 自己的
@property (nonatomic, weak  ) MusicPlayBar    * playbar;
@property (nonatomic, strong) UITableView     * infoTV;
@property (nonatomic, strong) UITableView     * musicListTV;
@property (nonatomic, weak  ) NSMutableArray<FileEntity> * itemArray;

@property (nonatomic, strong) UISearchBar     * searchBar;
@property (nonatomic, strong) UIView          * searchCoverView;
//@property (nonatomic, getter=isSearchTypeOld) BOOL searchTypeOld;// 显示搜索模式
//@property (nonatomic, getter=isSearchType) BOOL searchType;// 显示搜索模式
@property (nonatomic, strong) NSMutableArray<FileEntity> * _Nullable searchArray;

@property (nonatomic, strong) UIButton        * aimBT;

@property (nonatomic, readonly, getter=isRoot) BOOL root;
@property (nonatomic, readonly) FileType folderType;// 假如非Root, 则需要标注文件夹类型

@property (nonatomic, strong) UIMenuController * _Nullable longPressMenu;

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

- (void)aimAtCurrentItem:(UIButton *)bt;


// 长按手势
- (void)cellGrNullAction_all;
- (void)cellGrEditFileNameAction;
- (void)cellGrDeleteFileAction;
- (void)cellGrAddFolderAction; // 添加文件到歌单

- (void)cellGrCopySingerNameAction;
- (void)cellGrCopySongNameAction;
- (void)cellGrCopyFileNameAction;

@end

NS_ASSUME_NONNULL_END
