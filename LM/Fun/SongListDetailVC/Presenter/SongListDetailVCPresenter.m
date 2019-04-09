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

@end

@implementation SongListDetailVCPresenter

- (id)init {
    if (self = [super init]) {
        self.mpb = MpbShare;
        [self initInteractors];
        
    }
    return self;
}

- (void)setMyView:(id<SongListDetailVCProtocol>)view {
    self.view = view;
}

- (void)initInteractors {
    if (!self.interactor) {
        self.interactor = [SongListDetailVCInteractor new];
    }
}

#pragma mark - VC_DataSource
#pragma mark - TV_Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.view.infoTV) {
        return self.view.listEntity.array.count;
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
        return 10;
    }else{
        return 0.1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView == self.view.infoTV) {
        return 10;
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
        MusicPlayItemEntity * item = self.view.listEntity.array[indexPath.row];
        
        cell.titelL.text = [NSString stringWithFormat:@"%li: %@", indexPath.row+1, item.musicTitle];
        cell.timeL.text  = item.musicAuthor;
        
        if ([item.filePath isEqualToString:self.mpb.currentItem.filePath]) {
            cell.titelL.textColor = ColorThemeBlue1;
            cell.timeL.textColor  = ColorThemeBlue1;
            cell.rightIV.hidden   = NO;
            self.lastCell = cell;
            //cell.backgroundColor = [UIColor redColor];
        }else{
            cell.titelL.textColor = [UIColor blackColor];
            cell.timeL.textColor  = [UIColor grayColor];
            cell.rightIV.hidden   = YES;
            //cell.backgroundColor = [UIColor whiteColor];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //NSMutableArray * array = self.view.listEntity;
    if (tableView == self.view.infoTV) {
        [MpbShare playMusicPlayListEntity:self.view.listEntity at:indexPath.row];
        
        if (self.lastCell) {
            self.lastCell.titelL.textColor = [UIColor blackColor];
            self.lastCell.timeL.textColor  = [UIColor grayColor];
            self.lastCell.rightIV.hidden   = YES;
        }
        {
            MusicInfoCell * cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.titelL.textColor = ColorThemeBlue1;
            cell.timeL.textColor  = ColorThemeBlue1;
            cell.rightIV.hidden   = NO;
            
            self.lastCell = cell;
        }
    }else{
        MusicPlayListEntity * le = self.view.listEntity;
        [le sortArray:(MpViewOrder)indexPath.row];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view.infoTV reloadData];
            [self.view.alertBubbleTV reloadData];
            
            // 更新列表
            [self.mpb.mplt updateList];
            
            // 更新数字配置
            MusicPlayListEntity * le = self.mpb.mplt.list.array[self.mpb.mplt.config.listIndex];
            if (self.view.listEntity == le) {
                NSUInteger itemIndex = [le.array indexOfObject:self.mpb.currentItem];
                self.mpb.mplt.config.itemIndex = itemIndex;
                [self.mpb.mplt updateConfig];
            }
        });
    }
}

#pragma mark - tv 移动
// 这个回调实现了以后，就会出现更换位置的按钮，回调本身用来处理更换位置后的数据交换。
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (tableView == self.view.infoTV) {
        [self.view.listEntity.array exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
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
        //        @weakify(self);
        //        UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"重命名" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        //            @strongify(self);
        //            [self reListNameActionIndex:indexPath];
        //        }];
        //
        //        UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        //            [MpltShare.list.array removeObjectAtIndex:indexPath.row];
        //            [MpltShare updateList];
        //
        //            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //        }];
        //
        //        return @[action1, action0];
        
        return nil;
    }else{
        return nil;
    }
}

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
    
    [abView showCustomView:self.view.alertBubbleTV around:fromRect close:nil];
    
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
    [self.mpb.mplt updateList];
}

- (void)defaultNcRightItem {
    {
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"排序" style:UIBarButtonItemStylePlain target:self action:@selector(showSortTVAlertAction:event:)];
        UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStylePlain target:self action:@selector(editCustomAscendAction)];
        
        self.view.vc.navigationItem.rightBarButtonItems = @[item1, item2];
    }
    {
        self.view.infoTV.editing = NO;
    }
}

- (void)freshTVVisiableCellEvent {
    [self.view.infoTV reloadRowsAtIndexPaths:[self.view.infoTV indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)aimAtCurrentItem:(UIButton *)bt {
    MusicPlayListEntity * le = self.mpb.mplt.list.array[self.mpb.mplt.config.listIndex];
    if (self.view.listEntity == le) {
        [self.view.infoTV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.mpb.mplt.config.itemIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }else{
        AlertToastTitle(@"未播放该歌单");
    }
}

@end
