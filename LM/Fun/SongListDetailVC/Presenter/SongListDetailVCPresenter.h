//
//  SongListDetailVCPresenter.h
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.

#import <Foundation/Foundation.h>
#import "SongListDetailVCProtocol.h"

// 处理和View事件
@interface SongListDetailVCPresenter : NSObject <SongListDetailVCEventHandler, SongListDetailVCDataSource, UITableViewDelegate, UITableViewDataSource>

- (void)setMyView:(id)view;
- (void)initInteractors;

@end
