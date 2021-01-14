//
//  AppSetVCPresenter.m
//  LM
//
//  Created by popor on 2021/1/14.
//  Copyright © 2021 popor. All rights reserved.

#import "AppSetVCPresenter.h"
#import "AppSetVCInteractor.h"

#import "MusicConfig.h"

@interface AppSetVCPresenter ()

@property (nonatomic, weak  ) id<AppSetVCProtocol> view;
@property (nonatomic, strong) AppSetVCInteractor * interactor;

@property (nonatomic, weak  ) MusicConfigShare * configShare;

@end

@implementation AppSetVCPresenter

- (id)init {
    if (self = [super init]) {
        self.configShare = [MusicConfigShare share];
    }
    return self;
}

- (void)setMyInteractor:(AppSetVCInteractor *)interactor {
    self.interactor = interactor;
    
}

- (void)setMyView:(id<AppSetVCProtocol>)view {
    self.view = view;
    
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    
    
}

#pragma mark - VC_DataSource
#pragma mark - TV_Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.interactor.cellCieArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellInfoEntity * cie = self.interactor.cellCieArray[indexPath.row];
    SwitchCell * cell = [tableView dequeueReusableCellWithIdentifier:cie.title];
    if (!cell) {
        cell = [[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cie.title];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.textColor = App_colorTextN1;
    }
    
    cell.textLabel.text = cie.title;
    @weakify(self);
    
    switch (cie.tag) {
        case AppSetCellType_启动自动播放: {
            if (!cell.switchBlock) {
                cell.switchBlock = ^(UISwitch *uis) {
                    @strongify(self);
                    self.configShare.config.autoPlay = uis.on;
                    
                    [MGJRouter openURL:MUrl_savePlayConfig];
                };
            }
            cell.uis.on = self.configShare.config.autoPlay;
            break;
        }
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - VC_EventHandler

#pragma mark - Interactor_EventHandler

@end
