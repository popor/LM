//
//  LocalMusicVCProtocol.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "MusicPlayboard.h"

// MARK: 对外接口
@protocol LocalMusicVCProtocol <NSObject>

- (UIViewController *)vc;
- (void)setMyPresent:(id)present;

// MARK: 自己的
@property (nonatomic, weak  ) MusicPlayboard  * musicPlayboard;
@property (nonatomic, strong) UITableView     * infoTV;
@property (nonatomic, weak  ) NSMutableArray  * itemArray;


// MARK: 外部注入的

@end

// MARK: 数据来源
@protocol LocalMusicVCDataSource <NSObject>

@end

// MARK: UI事件
@protocol LocalMusicVCEventHandler <NSObject>

@end
