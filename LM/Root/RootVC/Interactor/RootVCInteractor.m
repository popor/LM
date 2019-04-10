//
//  RootVCInteractor.m
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import "RootVCInteractor.h"

@interface RootVCInteractor ()

@end

@implementation RootVCInteractor

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - VCDataSource
- (void)autoCheckUpdateAtVC:(UIViewController *)vc {
    @weakify(self);
    [AppVersionCheck autoAlertCheckVersionAtVc:vc finish:^(BOOL value) {
        @strongify(self);
        //value = YES;
        self.needFresh  = value;
        self.needUpdate = value;
    }];
}

@end
