//
//  SongListVCPresenter.m
//  LM
//
//  Created by popor on 2020/9/20.
//  Copyright © 2020 popor. All rights reserved.

#import "SongListVCPresenter.h"
#import "SongListVCInteractor.h"

#import "MusicPlayTool.h"
#import "MusicPlayListTool.h"

#import "WifiAddFileVC.h"
#import "LocalMusicVC.h"
#import "SongListDetailVC.h"

#import "MusicListCell.h"
#import "MusicPlayListTool.h"


@interface SongListVCPresenter ()

@property (nonatomic, weak  ) id<SongListVCProtocol> view;
@property (nonatomic, strong) SongListVCInteractor * interactor;

@property (nonatomic, weak  ) MusicPlayListTool * mplt;

@property (nonatomic, weak  ) SongListHeadView * headView;
@property (nonatomic        ) BOOL edit;

@end

@implementation SongListVCPresenter

- (id)init {
    if (self = [super init]) {
        self.mplt = MpltShare;
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
#pragma mark - TV_Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = MpltShare.list.songListArray.count;
    return MAX(1, count);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

//#import <PoporUI/UILabel+pInsets.h>

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SongListHeadView * head = (SongListHeadView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"headerView"];
    if (!head) {
        head = ({
            SongListHeadView * head = [SongListHeadView new];
            
            [head.addBT addTarget:self action:@selector(addListAction) forControlEvents:UIControlEventTouchUpInside];
            [head.editBT addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
            
            head;
        });
        
        self.headView = head;
    }
    
    head.editBT.selected = self.edit;
    head.addBT.hidden    = self.edit;
    
    return head;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellID = @"CellIDInfo0";
    MusicListCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell) {
        cell = [[MusicListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.tintColor      = ColorThemeBlue1;
    }
    MusicPlayListEntity * list = MpltShare.list.songListArray[indexPath.row];
    if (list) {
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
        cell.cellData = list;
        cell.titelL.text = [NSString stringWithFormat:@"%@ (%li)", list.name, list.itemArray.count];
        
        if(self.mplt.config.songIndexList == indexPath.row){
            cell.rightIV.hidden = NO;
            cell.titelL.textColor = ColorThemeBlue1;
        }else{
            cell.rightIV.hidden = YES;
            cell.titelL.textColor = [UIColor darkGrayColor];
        }
    } else {
        cell.cellData = list;
        cell.titelL.text = @"请新增歌单";
        cell.accessoryType  = UITableViewCellAccessoryNone;
        cell.rightIV.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.view.infoTV.isEditing) {
        return;
    }
    MusicPlayListEntity * list = MpltShare.list.songListArray[indexPath.row];
    if (list) {
        @weakify(self);
        BlockPBool deallocBlock = ^(BOOL value){
            @strongify(self);
            [self.view.infoTV reloadData];
        };
        
        NSDictionary * dic =
        @{@"title":list.name,
          @"listEntity":list,
          @"deallocBlock":deallocBlock,
        };
        [self.view.vc.navigationController pushViewController:[[SongListDetailVC alloc] initWithDic:dic] animated:YES];
    } else {
        [self addListAction];
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
        [MpltShare.list.songListArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        [MpltShare updateList];
    }else{
        
    }
    
}


#pragma mark - tv 删除 目前有ios11 和 之前代码区分
// 这个回调决定了在当前indexPath的Cell是否可以移动。
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.infoTV) {
        return YES;
    }else{
        return NO;
    }
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
    if (tableView == self.view.infoTV) {
        if (@available(iOS 11.0, *)) {
            @weakify(self);
            
            UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                @strongify(self);
                
                [MpltShare.list.songListArray removeObjectAtIndex:indexPath.row];
                [MpltShare updateList];
                
                [self.view.infoTV deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                completionHandler(YES);
            }];
            //也可以设置图片
            deleteAction.backgroundColor = [UIColor grayColor];
            
            UIContextualAction *renameAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"重命名" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                @strongify(self);
                [self reListNameActionIndex:indexPath];
                
                completionHandler(YES);
            }];
            //也可以设置图片
            renameAction.backgroundColor = [UIColor lightGrayColor];
            
            
            UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction, renameAction]];
            return config;
        } else {
            // Fallback on earlier versions
            return nil;
        }
    } else {
        return nil;
    }
}

#else
// 只要实现了这个方法，左滑出现按钮的功能就有了
//(一旦左滑出现了N个按钮，tableView就进入了编辑模式, tableView.editing = YES)
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath { }

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.infoTV) {
        @weakify(self);
        UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"重命名" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            @strongify(self);
            [self reListNameActionIndex:indexPath];
        }];
        
        UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            @strongify(self);
            
            [MpltShare.list.array removeObjectAtIndex:indexPath.row];
            [MpltShare updateList];
            
            [self.view.infoTV deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
        
        return @[action1, action0];
    }else{
        return nil;
    }
}

#endif


- (void)reListNameActionIndex:(NSIndexPath *)indexPath {
    MusicPlayListEntity * list = MpltShare.list.songListArray[indexPath.row];
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
//- (void)showWifiVC {
//
//    [UIView animateWithDuration:0.15 animations:^{
//        [self.view.playbar mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.bottom.mas_equalTo(self.view.playbar.height);
//        }];
//        [self.view.playbar.superview layoutIfNeeded];
//    }];
//
//    @weakify(self);
//    BlockPVoid deallocBlock = ^(void) {
//        @strongify(self);
//        [UIView animateWithDuration:0.15 animations:^{
//            [self.view.playbar mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.bottom.mas_equalTo(0);
//            }];
//            [self.view.playbar.superview layoutIfNeeded];
//        }];
//    };
//    NSDictionary * dic = @{@"deallocBlock":deallocBlock};
//
//    [self.view.vc.navigationController pushViewController:[[WifiAddFileVC alloc] initWithDic:dic] animated:YES];
//}

- (void)showLocalMusicVC {
    @weakify(self);
    BlockPVoid deallocBlock = ^(void){
        @strongify(self);
        [self.view.infoTV reloadData];
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

- (void)editAction:(UIButton *)bt {
    self.edit = !self.edit;
    bt.selected = self.edit;
    self.headView.addBT.hidden = self.edit;
    
    if (self.edit) {
        self.view.infoTV.allowsSelectionDuringEditing = NO;
        self.view.infoTV.editing = YES;
    } else {
        self.view.infoTV.editing = NO;
    }
}

- (void)checkVersion {
//    [self.interactor oneCheckUpdateAtVC:self.view.vc];
}

#pragma mark - Interactor_EventHandler
@end
