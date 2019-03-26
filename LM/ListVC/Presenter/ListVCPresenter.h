//
//  ListVCPresenter.h
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import <Foundation/Foundation.h>
#import "ListVCProtocol.h"

// 处理和View事件
@interface ListVCPresenter : NSObject <ListVCEventHandler, ListVCDataSource>

- (void)setMyView:(id)view;
- (void)initInteractors;

@end
