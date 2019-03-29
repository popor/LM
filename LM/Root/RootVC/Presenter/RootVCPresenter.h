//
//  RootVCPresenter.h
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import <Foundation/Foundation.h>
#import "RootVCProtocol.h"

// 处理和View事件
@interface RootVCPresenter : NSObject <RootVCEventHandler, RootVCDataSource, UITableViewDelegate, UITableViewDataSource>

- (void)setMyView:(id)view;
- (void)initInteractors;

@end
