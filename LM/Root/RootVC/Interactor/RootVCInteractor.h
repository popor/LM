//
//  RootVCInteractor.h
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import <Foundation/Foundation.h>
#import "AppVersionCheck.h"

// 处理Entity事件
@interface RootVCInteractor : NSObject

@property (nonatomic        ) BOOL needFresh;
@property (nonatomic        ) BOOL needUpdate;

- (void)autoCheckUpdateAtVC:(UIViewController *)vc;

@end
