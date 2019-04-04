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

#import "WifiAddFileVCRouter.h"
#import "LocalMusicVCRouter.h"
#import "SongListDetailVCRouter.h"

#import "MusicListCell.h"

@interface RootVCPresenter ()

@property (nonatomic, weak  ) id<RootVCProtocol> view;
@property (nonatomic, strong) RootVCInteractor * interactor;

@end

@implementation RootVCPresenter

- (id)init {
    if (self = [super init]) {
        [self initInteractors];
        
    }
    return self;
}

- (void)setMyView:(id<RootVCProtocol>)view {
    self.view = view;
}

- (void)initInteractors {
    if (!self.interactor) {
        self.interactor = [RootVCInteractor new];
    }
}

#pragma mark - VC_DataSource
#pragma mark - TV_Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.view.alertBubbleTV) {
        return RootMoreArray.count;
    }else{
        return MpltShare.list.array.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.alertBubbleTV) {
        return 44;
    }else{
        return 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.view.alertBubbleTV) {
        return 0.1;
    }else{
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView == self.view.alertBubbleTV) {
        return 0.1;
    }else{
        return 10;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.alertBubbleTV) {
        static NSString * CellID = @"CellID";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            //cell.backgroundColor = self.alertBubbleTVColor;
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        
        cell.textLabel.text = RootMoreArray[indexPath.row];
        
        return cell;
    }else{
        static NSString * CellID = @"CellID";
        MusicListCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        if (!cell) {
            cell = [[MusicListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
            
            [[cell.playBt rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                //x 就是被点击的按钮
                MusicListCell * scell = (MusicListCell *)x.superview;
                MusicPlayListEntity * list = (MusicPlayListEntity *)scell.cellData;
                
                [MpbShare playTempArray:list.array at:0];
            }];
        }
        MusicPlayListEntity * list = MpltShare.list.array[indexPath.row];
        cell.cellData = list;
        cell.titelL.text = [NSString stringWithFormat:@"%@ (%li)", list.name, list.array.count];
        
        return cell;
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
                [self showLocalMusicVC];
                break;
            }
            case 3:{
                [self startEditAction];
                break;
            }
            default:
                break;
        }
        
    }else{
        if (self.view.infoTV.isEditing) {
            return;
        }
        MusicPlayListEntity * list = MpltShare.list.array[indexPath.row];
        NSDictionary * dic = @{@"title":list.name,
                               @"listEntity":list,
                               
                               };
        [self.view.vc.navigationController pushViewController:[SongListDetailVCRouter vcWithDic:dic] animated:YES];
    }
    
}

#pragma mark - 编辑tv
// 这个回调决定了在当前indexPath的Cell是否可以编辑。
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

#pragma mark - tv 移动
// 这个回调实现了以后，就会出现更换位置的按钮，回调本身用来处理更换位置后的数据交换。
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (tableView == self.view.infoTV) {
        [MpltShare.list.array exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        [MpltShare updateList];
    }else{
        
    }
    
}

// 这个回调决定了在当前indexPath的Cell是否可以移动。
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.infoTV) {
        return YES;
    }else{
        return NO;
    }
}


#pragma mark - tv 删除
// 只要实现了这个方法，左滑出现按钮的功能就有了
// (一旦左滑出现了N个按钮，tableView就进入了编辑模式, tableView.editing = YES)
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.view.infoTV) {
        @weakify(self);
        UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"重命名" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            @strongify(self);
            [self reListNameActionIndex:indexPath];
        }];
        
        UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [MpltShare.list.array removeObjectAtIndex:indexPath.row];
            [MpltShare updateList];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
        
        return @[action1, action0];
    }else{
        return nil;
    }
}

- (void)reListNameActionIndex:(NSIndexPath *)indexPath {
    MusicPlayListEntity * list = MpltShare.list.array[indexPath.row];
    @weakify(self);
    {
        UIAlertController * oneAC = [UIAlertController alertControllerWithTitle:@"修改" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [oneAC addTextFieldWithConfigurationHandler:^(UITextField *textField){
            
            textField.placeholder = @"名称";
            textField.text = list.name;
        }];
        
        UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction * changeAction = [UIAlertAction actionWithTitle:@"修改" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self);
            UITextField * nameTF = oneAC.textFields[0];
            if (nameTF.text.length > 0) {
                list.name = nameTF.text;
                [MpltShare updateList];
                [self.view.infoTV reloadData];
            }
        }];
        
        [oneAC addAction:cancleAction];
        [oneAC addAction:changeAction];
        
        [self.view.vc presentViewController:oneAC animated:YES completion:nil];
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
    
    [self.view.vc.navigationController pushViewController:[WifiAddFileVCRouter vcWithDic:dic] animated:YES];
}

- (void)showLocalMusicVC {
    @weakify(self);
    BlockPVoid deallocBlock = ^(void){
        @strongify(self);
        [self.view.infoTV reloadData];
    };
    NSDictionary * dic = @{@"deallocBlock":deallocBlock};
    [self.view.vc.navigationController pushViewController:[LocalMusicVCRouter vcWithDic:dic] animated:YES];
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
        UIAlertAction * changeAction = [UIAlertAction actionWithTitle:@"创建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField * nameTF = oneAC.textFields[0];
            if (nameTF.text.length > 0) {
                [MpltShare addListName:nameTF.text];
                
                [weakSelf.view.infoTV reloadData];
            }
        }];
        
        [oneAC addAction:cancleAction];
        [oneAC addAction:changeAction];
        
        [self.view.vc presentViewController:oneAC animated:YES completion:nil];
    }
}

- (void)startEditAction {
    {
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(endEditAction)];
        self.view.vc.navigationItem.rightBarButtonItems = @[item1];
    }
    {
        self.view.infoTV.allowsSelectionDuringEditing = NO;
        self.view.infoTV.editing = YES;
    }
}

- (void)endEditAction {
    {
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(showTVAlertAction:event:)];
        self.view.vc.navigationItem.rightBarButtonItems = @[item1];
    }
    {
        self.view.infoTV.editing = NO;
    }
}

#pragma mark - Interactor_EventHandler

@end
