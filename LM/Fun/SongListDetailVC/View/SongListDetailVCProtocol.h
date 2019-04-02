//
//  SongListDetailVCProtocol.h
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "MusicPlayBar.h"
#import "MusicPlayListTool.h"

// MARK: 对外接口
@protocol SongListDetailVCProtocol <NSObject>

- (UIViewController *)vc;
- (void)setMyPresent:(id)present;

// MARK: 自己的
@property (nonatomic, strong) UITableView  * infoTV;
@property (nonatomic, weak  ) MusicPlayBar * playbar;

// MARK: 外部注入的
@property (nonatomic, weak  ) NSMutableArray * listArray;

@end

// MARK: 数据来源
@protocol SongListDetailVCDataSource <NSObject>

@end

// MARK: UI事件
@protocol SongListDetailVCEventHandler <NSObject>

@end
