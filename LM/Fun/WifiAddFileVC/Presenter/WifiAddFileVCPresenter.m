//
//  WifiAddFileVCPresenter.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import "WifiAddFileVCPresenter.h"
#import "WifiAddFileVCInteractor.h"

@interface WifiAddFileVCPresenter ()

@property (nonatomic, weak  ) id<WifiAddFileVCProtocol> view;
@property (nonatomic, strong) WifiAddFileVCInteractor * interactor;

@end

@implementation WifiAddFileVCPresenter

- (id)init {
    if (self = [super init]) {
        [self initInteractors];
        
    }
    return self;
}

- (void)setMyView:(id<WifiAddFileVCProtocol>)view {
    self.view = view;
}

- (void)initInteractors {
    if (!self.interactor) {
        self.interactor = [WifiAddFileVCInteractor new];
    }
}

#pragma mark - VC_DataSource

#pragma mark - VC_EventHandler

#pragma mark - Interactor_EventHandler

@end
