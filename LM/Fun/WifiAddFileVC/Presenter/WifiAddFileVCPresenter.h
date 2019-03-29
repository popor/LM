//
//  WifiAddFileVCPresenter.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import <Foundation/Foundation.h>
#import "WifiAddFileVCProtocol.h"

// 处理和View事件
@interface WifiAddFileVCPresenter : NSObject <WifiAddFileVCEventHandler, WifiAddFileVCDataSource>

- (void)setMyView:(id)view;
- (void)initInteractors;

@end
