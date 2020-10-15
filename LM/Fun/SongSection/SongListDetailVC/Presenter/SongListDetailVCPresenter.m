//
//  SongListDetailVCPresenter.m
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.

#import "SongListDetailVCPresenter.h"
#import "SongListDetailVCInteractor.h"

#import "MusicInfoCell.h"
#import "MusicPlayBar.h"

@interface SongListDetailVCPresenter ()

@property (nonatomic, weak  ) id<SongListDetailVCProtocol> view;
@property (nonatomic, strong) SongListDetailVCInteractor * interactor;

@property (nonatomic, weak  ) MusicPlayBar * mpb;
@property (nonatomic, weak  ) MusicInfoCell * lastCell;

@property (nonatomic        ) BOOL firstAimAt;

@end

@implementation SongListDetailVCPresenter

- (id)init {
    if (self = [super init]) {
        self.mpb = MpbShare;
        self.firstAimAt = YES;
    }
    return self;
}

- (void)setMyInteractor:(SongListDetailVCInteractor *)interactor {
    self.interactor = interactor;
    
}

- (void)setMyView:(id<SongListDetailVCProtocol>)view {
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
    if (tableView == self.view.infoTV) {
        if (self.view.isSearchType) {
            return self.view.searchArray.count;
        }else{
            return self.view.listEntity.itemArray.count;
        }
    }else{
        return MpViewOrderTitleArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.infoTV) {
        return MusicInfoCellH;
    }else{
        return SongListDetailVCSortTvCellH;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.view.infoTV) {
        return self.view.searchBar.height;
    }else{
        return 0.1;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.view.infoTV) {
        return self.view.searchBar;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView == self.view.infoTV) {
        return 0.1;
    }else{
        return 0.1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.infoTV) {
        static NSString * CellID = @"CellIDInfo";
        MusicInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        if (!cell) {
            cell = [[MusicInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID type:MusicInfoCellTypeDefault];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.addBt.userInteractionEnabled = NO;
            [cell.addBt setImage:nil forState:UIControlStateNormal];
        }
        FileEntity * item;
        if (self.view.isSearchType) {
            item = self.view.searchArray[indexPath.row];
        }else{
            item = self.view.listEntity.itemArray[indexPath.row];
        }
        
        cell.titelL.text = [NSString stringWithFormat:@"%li: %@", indexPath.row+1, item.musicName];
        cell.timeL.text  = item.musicAuthor;
        
        if ([item.filePath isEqualToString:self.mpb.currentItem.filePath]) {
            cell.titelL.textColor = ColorThemeBlue1;
            cell.timeL.textColor  = ColorThemeBlue1;
            cell.rightIV.hidden   = NO;
            self.lastCell = cell;
        }else{
            cell.titelL.textColor = App_textNColor;
            cell.timeL.textColor  = App_textNColor2;
            cell.rightIV.hidden   = YES;
        }
        if (self.view.isSearchType) {
            [self attLable:cell.titelL searchText:self.view.searchBar.text];
            [self attLable:cell.timeL searchText:self.view.searchBar.text];
        }
        // 打开cover的话,内存会达到100MB以上.
        //if (!item.musicCover) {
        //    item.musicCover = [item coverImage];
        //}
        //[cell.addBt setImage:item.musicCover forState:UIControlStateNormal];
        
        return cell;
    }else{
        static NSString * CellID = @"CellIDAlert";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            //cell.backgroundColor = self.alertBubbleTVColor;
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        
        cell.textLabel.text = MpViewOrderTitleArray[indexPath.row];
        if ((MpViewOrder)indexPath.row == self.view.listEntity.viewOrder) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
    }
    
}

- (void)attLable:(UILabel *)cellL searchText:(NSString *)searchText {
    if ([cellL.text.lowercaseString containsString:searchText.lowercaseString]) {
        NSMutableAttributedString * attBase = [NSMutableAttributedString new];
        [attBase addString:cellL.text font:cellL.font color:cellL.textColor];
        
        NSRange range = [cellL.text.lowercaseString rangeOfString:searchText.lowercaseString];
        
        NSMutableAttributedString * attReplace = [NSMutableAttributedString new];
        [attReplace addString:[cellL.text substringWithRange:range] font:cellL.font color:[UIColor redColor]];
        
        [attBase replaceCharactersInRange:range withAttributedString:attReplace];
        
        cellL.attributedText = attBase;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //NSMutableArray * array = self.view.listEntity;
    if (tableView == self.view.infoTV) {
        
        // 播放音频
        if (self.view.isSearchType) {
            self.mpb.mplt.config.songIndexList = [self.mpb.mplt.list.songListArray indexOfObject:self.view.listEntity];
            [MpbShare playLocalListArray:self.view.searchArray folder:nil type:McPlayType_searchSongList at:indexPath.row];
        }else{
            [MpbShare playSongListEntity:self.view.listEntity at:indexPath.row];
        }
        
        // 刷新UI
        if (self.lastCell) {
            self.lastCell.titelL.textColor = App_textNColor;
            self.lastCell.timeL.textColor  = App_textNColor2;
            self.lastCell.rightIV.hidden   = YES;
            
            // 刷新搜索状态
            if (self.view.isSearchType) {
                [self attLable:self.lastCell.titelL searchText:self.view.searchBar.text];
                [self attLable:self.lastCell.timeL searchText:self.view.searchBar.text];
            }
        }
        {
            MusicInfoCell * cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.titelL.textColor = ColorThemeBlue1;
            cell.timeL.textColor  = ColorThemeBlue1;
            cell.rightIV.hidden   = NO;
            self.lastCell = cell;
            
            // 刷新搜索状态
            if (self.view.isSearchType) {
                [self attLable:self.lastCell.titelL searchText:self.view.searchBar.text];
                [self attLable:self.lastCell.timeL searchText:self.view.searchBar.text];
            }
        }
        
    }else{
        MusicPlayListEntity * le = self.view.listEntity;
        [le sortArray:(MpViewOrder)indexPath.row];
        [self defaultNcRightItem];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view.infoTV reloadData];
            [self.view.alertBubbleTV reloadData];
            
            // 更新列表
            [self.mpb.mplt updateSongList];
            
            // 更新数字配置
            MusicPlayListEntity * le = self.mpb.mplt.list.songListArray[self.mpb.mplt.config.songIndexList];
            if (self.view.listEntity == le) {
                NSUInteger itemIndex = [le.itemArray indexOfObject:self.mpb.currentItem];
                self.mpb.mplt.config.songIndexItem = itemIndex;
            }
        });
    }
}

#pragma mark - tv 移动
// 这个回调实现了以后，就会出现更换位置的按钮，回调本身用来处理更换位置后的数据交换。
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (tableView == self.view.infoTV) {
        FileEntity * ie0 = self.view.listEntity.itemArray[sourceIndexPath.row];
        FileEntity * ie1 = self.view.listEntity.itemArray[destinationIndexPath.row];
        NSInteger i = ie0.index;
        ie0.index   = ie1.index;
        ie1.index   = i;
        
        [self.view.listEntity.itemArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
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


#pragma mark - tv 删除 目前有ios11 和 之前代码区分
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.infoTV) {
        return tableView.isEditing;
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
                
                self.view.needUpdateSuperVC = YES;
                [self.view.listEntity.itemArray removeObjectAtIndex:indexPath.row];
                [MpltShare updateSongList];
                
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                completionHandler(YES);
            }];
            //也可以设置图片
            deleteAction.backgroundColor = [UIColor grayColor];
            
            
            UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
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
// (一旦左滑出现了N个按钮，tableView就进入了编辑模式, tableView.editing = YES)
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath { }

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.infoTV) {
        @weakify(self);
        
        UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            @strongify(self);
            self.view.needUpdateSuperVC = YES;
            [self.view.listEntity.array removeObjectAtIndex:indexPath.row];
            [MpltShare updateList];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
        
        return @[action1];
    }else{
        return nil;
    }
}

#endif

#pragma mark - VC_EventHandler

#pragma mark - Interactor_EventHandler
- (void)showSortTVAlertAction:(UIBarButtonItem *)sender event:(UIEvent *)event {
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
    
    self.view.vc.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    @weakify(self);
    [abView showCustomView:self.view.alertBubbleTV around:fromRect close:^{
        @strongify(self);
        self.view.vc.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }];
    
    self.view.alertBubbleView = abView;
}

- (void)editCustomAscendAction {
    if (self.view.listEntity.viewOrder == MpViewOrderCustomAscend) {
        [self startEditAction];
    }else{
        AlertToastTitle(@"只支持 [自定义: 正序] 模式");
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
    [self defaultNcRightItem];
    self.view.infoTV.editing = NO;
    [self.mpb.mplt updateSongList];
}

- (void)defaultNcRightItem {
    {
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"排序" style:UIBarButtonItemStylePlain target:self action:@selector(showSortTVAlertAction:event:)];
        
        UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStylePlain target:self action:@selector(editCustomAscendAction)];
        if (self.view.listEntity.viewOrder != MpViewOrderCustomAscend) {
            item2.tintColor = [UIColor lightGrayColor];
        }else{
            
        }
        
        self.view.vc.navigationItem.rightBarButtonItems = @[item1, item2];
    }
}

- (void)nilNcRightItem {
    self.view.vc.navigationItem.rightBarButtonItems = nil;
}

- (void)freshTVVisiableCellEvent {
    [self.view.infoTV reloadRowsAtIndexPaths:[self.view.infoTV indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)aimAtCurrentItem:(UIButton *)bt {
    MusicPlayListEntity * le = self.mpb.mplt.list.songListArray[self.mpb.mplt.config.songIndexList];
    if (!le) {
        return;
    }
    if (self.view.listEntity == le) {
        BOOL animation = YES;
        if (self.firstAimAt) {
            self.firstAimAt = NO;
            animation = NO;
        }
        
        if ([self.view.infoTV.dataSource tableView:self.view.infoTV numberOfRowsInSection:0] > self.mpb.mplt.config.songIndexItem) {
            [self.view.infoTV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.mpb.mplt.config.songIndexItem inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animation];
        }
    }else{
        if (self.firstAimAt) {
            self.firstAimAt = NO;
        }else{
            AlertToastTitle(@"未播放该歌单");
        }
    }
}

#pragma mark - mac 系统事件
- (void)listRenameAction {
    MusicPlayListEntity * list = self.view.listEntity;
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
                [MpltShare updateSongList];
                
                self.view.vc.title = nameTF.text;
            }
        }];
        
        [oneAC addAction:cancleAction];
        [oneAC addAction:changeAction];
        
        [self.view.vc presentViewController:oneAC animated:YES completion:nil];
    }
}

- (void)listDeleteAction {
    [MpltShare.list.songListArray removeObject:self.view.listEntity];
    [MpltShare updateSongList];
    
    [self.view.vc.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 搜索
- (void)searchAction:(UISearchBar *)bar {
    [self.view.searchArray removeAllObjects];
    NSString * text = bar.text.lowercaseString;
    for (FileEntity * item in self.view.listEntity.itemArray) {
        if ([item.fileName.lowercaseString containsString:text]) {
            [self.view.searchArray addObject:item];
        }
    }
    [self.view.infoTV reloadData];
}

@end
