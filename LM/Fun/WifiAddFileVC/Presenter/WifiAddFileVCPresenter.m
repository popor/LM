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
        
    }
    return self;
}

- (void)setMyInteractor:(WifiAddFileVCInteractor *)interactor {
    self.interactor = interactor;
    
}

- (void)setMyView:(id<WifiAddFileVCProtocol>)view {
    self.view = view;
    
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    
    
}

#pragma mark - VC_DataSource

#pragma mark - VC_EventHandler

#pragma mark - Interactor_EventHandler

@end
