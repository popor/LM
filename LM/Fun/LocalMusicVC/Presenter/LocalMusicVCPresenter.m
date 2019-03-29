//
//  LocalMusicVCPresenter.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import "LocalMusicVCPresenter.h"
#import "LocalMusicVCInteractor.h"

@interface LocalMusicVCPresenter ()

@property (nonatomic, weak  ) id<LocalMusicVCProtocol> view;
@property (nonatomic, strong) LocalMusicVCInteractor * interactor;

@end

@implementation LocalMusicVCPresenter

- (id)init {
    if (self = [super init]) {
        [self initInteractors];
        
    }
    return self;
}

- (void)setMyView:(id<LocalMusicVCProtocol>)view {
    self.view = view;
}

- (void)initInteractors {
    if (!self.interactor) {
        self.interactor = [LocalMusicVCInteractor new];
    }
}

#pragma mark - VC_DataSource

#pragma mark - VC_EventHandler

#pragma mark - Interactor_EventHandler

@end
