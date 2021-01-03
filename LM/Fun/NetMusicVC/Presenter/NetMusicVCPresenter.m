//
//  NetMusicVCPresenter.m
//  LM
//
//  Created by 王凯庆 on 2021/1/3.
//  Copyright © 2021 popor. All rights reserved.

#import "NetMusicVCPresenter.h"
#import "NetMusicVCInteractor.h"

@interface NetMusicVCPresenter ()

@property (nonatomic, weak  ) id<NetMusicVCProtocol> view;
@property (nonatomic, strong) NetMusicVCInteractor * interactor;

@end

@implementation NetMusicVCPresenter

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)setMyInteractor:(NetMusicVCInteractor *)interactor {
    self.interactor = interactor;
    
}

- (void)setMyView:(id<NetMusicVCProtocol>)view {
    self.view = view;
    
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    
    
}

#pragma mark - VC_DataSource

#pragma mark - VC_EventHandler

#pragma mark - Interactor_EventHandler

@end
