//
//  RootVCPresenter.m
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import "RootVCPresenter.h"
#import "RootVCInteractor.h"

#import "MusicPlayTool.h"
#import "MusicPlayListTool.h"

#import "WifiAddFileVC.h"
#import "SongListDetailVC.h"

#import "MusicListCell.h"
#import "MusicPlayListTool.h"

@interface RootVCPresenter ()

@property (nonatomic, weak  ) id<RootVCProtocol> view;
@property (nonatomic, strong) RootVCInteractor * interactor;
@property (nonatomic, weak  ) MusicPlayListTool * mplt;
@property (nonatomic        ) NSInteger recordDepartment;

@end

@implementation RootVCPresenter

- (id)init {
    if (self = [super init]) {
        self.mplt = MpltShare;
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
    
    self.recordDepartment = [self.interactor get__playDepartment];
    @weakify(self);
    [MRouterC registerURL:MUrl_savePlayDepartment toHandel:^(NSDictionary *routerParameters){
        @strongify(self);
        
        if (self.view.segmentView.currentPage != self.recordDepartment) {
            [self.interactor save__playDepartment:self.view.segmentView.currentPage];
        }
    }];
    
    [MRouterC registerURL:MUrl_wifiAddFileVC toHandel:^(NSDictionary *routerParameters){
        @strongify(self);
        
        [self showWifiVC];
    }];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.recordDepartment != 0) {
            [self.view.segmentView updateLineViewToBT:self.view.segmentView.btArray[self.recordDepartment]];
        }
    });
    
}

#pragma mark - VC_DataSource

#pragma mark - VC_EventHandler

- (void)showWifiVC {
    
    [UIView animateWithDuration:0.15 animations:^{
        [self.view.playbar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view.playbar.height);
        }];
        [self.view.playbar.superview layoutIfNeeded];
    }];
    
    @weakify(self);
    BlockPVoid deallocBlock = ^(void) {
        @strongify(self);
        [UIView animateWithDuration:0.15 animations:^{
            [self.view.playbar mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(0);
            }];
            [self.view.playbar.superview layoutIfNeeded];
        }];
    };
    NSDictionary * dic = @{@"deallocBlock":deallocBlock};
    
    [self.view.vc.navigationController pushViewController:[[WifiAddFileVC alloc] initWithDic:dic] animated:YES];
}

- (void)addListAction {
    __weak typeof(self) weakSelf = self;
    {
        UIAlertController * oneAC = [UIAlertController alertControllerWithTitle:@"创建新列表" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [oneAC addTextFieldWithConfigurationHandler:^(UITextField *textField){
            
            textField.placeholder = @"新列表名称";
            textField.text = @"";
        }];
        
        UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        @weakify(oneAC);
        UIAlertAction * changeAction = [UIAlertAction actionWithTitle:@"创建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            @strongify(oneAC);
            
            UITextField * nameTF = oneAC.textFields[0];
            if (nameTF.text.length > 0) {
                [MpltShare addListName:nameTF.text];
                
                [weakSelf.view.songListVC.infoTV reloadData];
            }
        }];
        
        [oneAC addAction:cancleAction];
        [oneAC addAction:changeAction];
        
        [self.view.vc presentViewController:oneAC animated:YES completion:nil];
    }
}

- (void)checkVersion {
    [self.interactor oneCheckUpdateAtVC:self.view.vc];
}

#pragma mark - Interactor_EventHandler

@end
