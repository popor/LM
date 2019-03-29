//
//  LocalMusicVCPresenter.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import <Foundation/Foundation.h>
#import "LocalMusicVCProtocol.h"

// 处理和View事件
@interface LocalMusicVCPresenter : NSObject <LocalMusicVCEventHandler, LocalMusicVCDataSource, UITableViewDelegate, UITableViewDataSource>

- (void)setMyView:(id)view;
- (void)initInteractors;

@end
