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
#import "LocalMusicVC.h"
#import "SongListDetailVC.h"

#import "MusicListCell.h"
#import "MusicPlayListTool.h"

@interface RootVCPresenter ()

@property (nonatomic, weak  ) id<RootVCProtocol> view;
@property (nonatomic, strong) RootVCInteractor * interactor;
@property (nonatomic, weak  ) MusicPlayListTool * mplt;

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
    
    
}

#pragma mark - VC_DataSource
#pragma mark - TV_Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RootMoreArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.alertBubbleTV) {
        static NSString * CellID = @"CellIDAlert";
        UITableViewCell * cell   = [tableView dequeueReusableCellWithIdentifier:CellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
            cell.selectionStyle  = UITableViewCellSelectionStyleDefault;
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.font  = [UIFont systemFontOfSize:15];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        if (indexPath.row == RootMoreCheckUpdate) {
            if (self.interactor.needUpdate) {
                cell.accessoryType = UITableViewCellAccessoryDetailButton;
                cell.tintColor     = [UIColor whiteColor];
            }else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = RootMoreArray[indexPath.row];
        
        return cell;
    } else {
        
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.view.alertBubbleTV) {
        [self.view.alertBubbleView closeEvent];
        switch (indexPath.row) {
            case 0:{
                [self addListAction];
                break;
            }
            case 1:{
                [self showWifiVC];
                break;
            }
            case 2:{
                [self startEditAction];
                break;
            }
            case 3:{
                [self checkVersion];
                break;
            }
            default:
                break;
        }
        
    }
    
}

#pragma mark - VC_EventHandler
- (void)showTVAlertAction:(UIBarButtonItem *)sender event:(UIEvent *)event {
    //CGRect fromRect = [[event.allTouches anyObject] view].frame;
    UITouch * touch = [event.allTouches anyObject];
    //UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    
    //CGPoint point = [touch locationInView:window];
    //fromRect.origin = point;
    
    CGRect fromRect = [touch.view.superview convertRect:touch.view.frame toView:self.view.vc.navigationController.view];
    fromRect.origin.y -= 8;
    
    NSDictionary * dic = @{
                           @"direction":@(AlertBubbleViewDirectionTop),
                           @"baseView":self.view.vc.navigationController.view,
                           @"borderLineColor":self.view.alertBubbleTVColor,
                           @"borderLineWidth":@(1),
                           @"corner":@(5),
                           @"trangleHeight":@(8),
                           @"trangleWidth":@(8),
                           
                           @"borderInnerGap":@(10),
                           @"customeViewInnerGap":@(0),
                           
                           @"bubbleBgColor":self.view.alertBubbleTVColor,
                           @"bgColor":[UIColor clearColor],
                           @"showAroundRect":@(NO),
                           @"showLogInfo":@(NO),
                           };
    
    AlertBubbleView * abView = [[AlertBubbleView alloc] initWithDic:dic];
    
    [abView showCustomView:self.view.alertBubbleTV around:fromRect close:nil];
    
    self.view.alertBubbleView = abView;
    
    if (self.interactor.needFresh) {
        self.interactor.needFresh = NO;
        [self.view.alertBubbleTV reloadData];
    }
}

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

- (void)showLocalMusicVC {
    @weakify(self);
    BlockPVoid deallocBlock = ^(void){
        @strongify(self);
        [self.view.songListVC.infoTV reloadData];
    };
    NSDictionary * dic = @{@"deallocBlock":deallocBlock};
    [self.view.vc.navigationController pushViewController:[[LocalMusicVC alloc] initWithDic:dic] animated:YES];
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

- (void)startEditAction {
//    {
//        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(endEditAction)];
//        self.view.vc.navigationItem.rightBarButtonItems = @[item1];
//    }
//    {
//        self.view.infoTV.allowsSelectionDuringEditing = NO;
//        self.view.infoTV.editing = YES;
//    }
}

- (void)endEditAction {
//    {
//        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(showTVAlertAction:event:)];
//        self.view.vc.navigationItem.rightBarButtonItems = @[item1];
//    }
//    {
//        self.view.infoTV.editing = NO;
//    }
}

- (void)checkVersion {
    [self.interactor oneCheckUpdateAtVC:self.view.vc];
}

#pragma mark - Interactor_EventHandler

@end
