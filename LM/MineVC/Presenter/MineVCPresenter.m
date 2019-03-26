//
//  MineVCPresenter.m
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import "MineVCPresenter.h"
#import "MineVCInteractor.h"

@interface MineVCPresenter ()

@property (nonatomic, weak  ) id<MineVCProtocol> view;
@property (nonatomic, strong) MineVCInteractor * interactor;

@end

@implementation MineVCPresenter

- (id)init {
    if (self = [super init]) {
        [self initInteractors];
        
    }
    return self;
}

- (void)setMyView:(id<MineVCProtocol>)view {
    self.view = view;
}

- (void)initInteractors {
    if (!self.interactor) {
        self.interactor = [MineVCInteractor new];
    }
}

#pragma mark - VC_DataSource

#pragma mark - VC_EventHandler

#pragma mark - Interactor_EventHandler

@end
