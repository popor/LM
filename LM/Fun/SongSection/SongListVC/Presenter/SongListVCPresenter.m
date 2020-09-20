//
//  SongListVCPresenter.m
//  LM
//
//  Created by popor on 2020/9/20.
//  Copyright © 2020 popor. All rights reserved.

#import "SongListVCPresenter.h"
#import "SongListVCInteractor.h"

@interface SongListVCPresenter ()

@property (nonatomic, weak  ) id<SongListVCProtocol> view;
@property (nonatomic, strong) SongListVCInteractor * interactor;

@end

@implementation SongListVCPresenter

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)setMyInteractor:(SongListVCInteractor *)interactor {
    self.interactor = interactor;
    
}

- (void)setMyView:(id<SongListVCProtocol>)view {
    self.view = view;
    
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    
    
}

#pragma mark - VC_DataSource

#pragma mark - VC_EventHandler

#pragma mark - Interactor_EventHandler

@end
