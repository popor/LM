//
//  RootVCPresenter.m
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import "RootVCPresenter.h"
#import "RootVCInteractor.h"

#import "MusicPlayTool.h"
#import "MusicFolderEntity.h"

#import "WifiAddFileVC.h"
//#import "SongListDetailVC.h"

#import "MusicListCell.h"
#import "MusicFolderEntity.h"

@interface RootVCPresenter ()

@property (nonatomic, weak  ) id<RootVCProtocol> view;
@property (nonatomic, strong) RootVCInteractor * interactor;

@end

@implementation RootVCPresenter

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)setMyInteractor:(RootVCInteractor *)interactor {
    self.interactor = interactor;
    
}

- (void)setMyView:(id<RootVCProtocol>)view {
    self.view = view;
    
    [self.interactor autoCheckUpdateAtVC:self.view.vc];
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    {
        @weakify(self);
        [MRouterC registerURL:MUrl_wifiAddFileVC toHandel:^(NSDictionary *routerParameters){
            @strongify(self);
            
            [self showWifiVC];
        }];
    }
    //    self.recordDepartment = [self.interactor get__playDepartment];
    //    @weakify(self);
    //    [MRouterC registerURL:MUrl_savePlayDepartment toHandel:^(NSDictionary *routerParameters){
    //        @strongify(self);
    //
    //        if (self.view.segmentView.currentPage != self.recordDepartment) {
    //            [self.interactor save__playDepartment:self.view.segmentView.currentPage];
    //        }
    //    }];
    //
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        if (self.recordDepartment != 0) {
    //            [self.view.segmentView updateLineViewToBT:self.view.segmentView.btArray[self.recordDepartment]];
    //        }
    //    });
    {
        
        @weakify(self);
        [MRouterC registerURL:MUrl_playBarOpen toHandel:^(NSDictionary *routerParameters){
            @strongify(self);
            
            [UIView animateWithDuration:0.15 animations:^{
                [self.view.playbar mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.mas_equalTo(0);
                }];
                [self.view.playbar.superview layoutIfNeeded];
            }];
        }];
        [MRouterC registerURL:MUrl_playBarClose toHandel:^(NSDictionary *routerParameters){
            @strongify(self);
            
            [UIView animateWithDuration:0.15 animations:^{
                [self.view.playbar mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.mas_equalTo(self.view.playbar.height);
                }];
                [self.view.playbar.superview layoutIfNeeded];
            }];
        }];
    }
}

#pragma mark - VC_DataSource

#pragma mark - VC_EventHandler

- (void)showWifiVC {
    
    [MGJRouter openURL:MUrl_playBarClose];
    [self.view.vc.navigationController pushViewController:[[WifiAddFileVC alloc] initWithDic:nil] animated:YES];
}

- (void)addListAction {}

- (void)checkVersion {
    [self.interactor oneCheckUpdateAtVC:self.view.vc];
}

#pragma mark - Interactor_EventHandler

@end
