//
//  ListVCPresenter.m
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import "ListVCPresenter.h"
#import "ListVCInteractor.h"

@interface ListVCPresenter ()

@property (nonatomic, weak  ) id<ListVCProtocol> view;
@property (nonatomic, strong) ListVCInteractor * interactor;

@end

@implementation ListVCPresenter

- (id)init {
    if (self = [super init]) {
        [self initInteractors];
        
    }
    return self;
}

- (void)setMyView:(id<ListVCProtocol>)view {
    self.view = view;
}

- (void)initInteractors {
    if (!self.interactor) {
        self.interactor = [ListVCInteractor new];
    }
}

#pragma mark - VC_DataSource

#pragma mark - VC_EventHandler

#pragma mark - Interactor_EventHandler

@end
