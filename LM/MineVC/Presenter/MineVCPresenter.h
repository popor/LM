//
//  MineVCPresenter.h
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import <Foundation/Foundation.h>
#import "MineVCProtocol.h"

// 处理和View事件
@interface MineVCPresenter : NSObject <MineVCEventHandler, MineVCDataSource>

- (void)setMyView:(id)view;
- (void)initInteractors;

@end
