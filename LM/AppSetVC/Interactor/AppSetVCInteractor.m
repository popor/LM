//
//  AppSetVCInteractor.m
//  LM
//
//  Created by popor on 2021/1/14.
//  Copyright © 2021 popor. All rights reserved.

#import "AppSetVCInteractor.h"

@interface AppSetVCInteractor ()

@end

@implementation AppSetVCInteractor

- (id)init {
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

#pragma mark - VCDataSource
- (void)initData {
    self.cellCieArray = [NSMutableArray new];
    
    self.cellCieArray.add(CIE_TT(AppSetCellType_启动自动播放, @"APP启动时自动播放"));
}

@end
