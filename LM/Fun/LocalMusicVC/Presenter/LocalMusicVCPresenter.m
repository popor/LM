//
//  LocalMusicVCPresenter.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import "LocalMusicVCPresenter.h"
#import "LocalMusicVCInteractor.h"

#import "LocalMusicVC.h"
#import "MusicInfoCell.h"

#import "MusicPlayListTool.h"
#import "MusicPlayBar.h"

@interface LocalMusicVCPresenter ()

@property (nonatomic, weak  ) id<LocalMusicVCProtocol> view;
@property (nonatomic, strong) LocalMusicVCInteractor * interactor;

@property (nonatomic, weak  ) FileEntity * selectFileEntity;
@property (nonatomic, weak  ) MusicPlayBar * mpb;
@property (nonatomic, weak  ) MusicInfoCell * lastCell;

@end

@implementation LocalMusicVCPresenter

- (id)init {
    if (self = [super init]) {
        self.mpb = MpbShare;
        
    }
    return self;
}

- (void)setMyInteractor:(LocalMusicVCInteractor *)interactor {
    self.interactor = interactor;
    
}

- (void)setMyView:(id<LocalMusicVCProtocol>)view {
    self.view = view;
    
    if (self.view.itemArray) {
        self.interactor.infoArray = self.view.itemArray;
    }else{
        [self.interactor initData];
    }
    [self.view.infoTV reloadData];
    
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
            return self.interactor.infoArray.count;
        }
        
    }else{
        return  MAX(MpltShare.list.array.count, 1);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.infoTV) {
        return MusicInfoCellH;
    }else{
        return  50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.view.infoTV) {
        if (self.view.isRoot) {
            return 10;
        }else{
            return self.view.searchBar.height;
        }
    }else{
        return 0.1;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.view.infoTV) {
        if (self.view.isRoot) {
            return nil;
        }else{
            return self.view.searchBar;
        }
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView == self.view.infoTV) {
        if (self.view.isRoot) {
            return 10;
        }else{
            return 0.1;
        }
    }else{
        return 0.1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.infoTV) {
        static NSString * CellID = @"CellFolder";
        MusicInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        if (!cell) {
            cell = [[MusicInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID type:MusicInfoCellTypeAdd];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (!self.view.itemArray) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            @weakify(self);
            @weakify(cell);
            [[cell.addBt rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                @strongify(cell);
                
                FileEntity * entity     = (FileEntity *)cell.cellData;
                self.selectFileEntity   = entity;
                
                [self addMusicPlistFile:entity];
            }];
        }
        
        FileEntity * entity;
        if (self.view.isSearchType) {
            entity = self.view.searchArray[indexPath.row];
        }else{
            entity = self.interactor.infoArray[indexPath.row];
        }
        
        if (entity.isFolder) {
            cell.titelL.text = entity.fileName;
            cell.timeL.text  = [NSString stringWithFormat:@"%li首", entity.itemArray.count];
        }else{
            cell.titelL.text = [NSString stringWithFormat:@"%li: %@", indexPath.row+1, entity.musicTitle];
            cell.timeL.text  = entity.musicAuthor;
            
            if ([entity.filePath isEqualToString:self.mpb.currentItem.filePath]) {
                cell.titelL.textColor = ColorThemeBlue1;
                cell.timeL.textColor  = ColorThemeBlue1;
                
                self.lastCell = cell;
            }else{
                cell.titelL.textColor = [UIColor blackColor];
                cell.timeL.textColor  = [UIColor grayColor];
            }
            
            if (self.view.isSearchType) {
                [self attLable:cell.titelL searchText:self.view.searchBar.text];
                [self attLable:cell.timeL searchText:self.view.searchBar.text];
            }
        }
        cell.cellData = entity;
        
        return cell;
    }
    
    else{
        static NSString * CellID = @"CellMusicList";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        MusicPlayListEntity * list = MpltShare.list.array[indexPath.row];
        if (list) {
            cell.textLabel.text = list.name;
        } else {
            cell.textLabel.text = @"请在首页 新增歌单";
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
    
    if (tableView == self.view.infoTV) {
        FileEntity * fileEntity;
        if (self.view.isSearchType) {
            fileEntity = self.view.searchArray[indexPath.row];
        }else{
            fileEntity = self.interactor.infoArray[indexPath.row];
        }
        
        if (fileEntity.isFolder) {
            NSDictionary * dic = @{@"title":fileEntity.fileName, @"itemArray":fileEntity.itemArray};
            [self.view.vc.navigationController pushViewController:[[LocalMusicVC alloc] initWithDic:dic] animated:YES];
        }else{
            // 播放本地列表的时候, 需要清空播放记录
            self.mpb.mplt.config.indexList = -1;
            self.mpb.mplt.config.indexItem = -1;
            [self.mpb.mplt updateConfig];
            
            NSArray * array = @[[MusicPlayItemEntity initWithFileEntity:fileEntity]];
            [self.mpb playTempArray:array at:0];
            
            if (self.lastCell) {
                self.lastCell.titelL.textColor = [UIColor blackColor];
                self.lastCell.timeL.textColor  = [UIColor grayColor];
                
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
                self.lastCell = cell;
                
                // 刷新搜索状态
                if (self.view.isSearchType) {
                    [self attLable:self.lastCell.titelL searchText:self.view.searchBar.text];
                    [self attLable:self.lastCell.timeL searchText:self.view.searchBar.text];
                }
            }
            
        }
    }
    
    else {
        MusicPlayListEntity * list = MpltShare.list.array[indexPath.row];
        if (list) {
            if (self.selectFileEntity.isFolder) {
                for (FileEntity * fileEntity in self.selectFileEntity.itemArray) {
                    MusicPlayItemEntity * ie = [MusicPlayItemEntity initWithFileEntity:fileEntity];
                    ie.index = list.recoredNum++;
                    list.array.add(ie);
                }
            }else{
                FileEntity * fileEntity    = self.selectFileEntity;
                MusicPlayItemEntity * ie = [MusicPlayItemEntity initWithFileEntity:fileEntity];
                ie.index = list.recoredNum++;
                list.array.add(ie);
            }
            [MpltShare updateList];
            
            AlertToastTitle(@"增加成功");
        } else {
            AlertToastTitle(@"请在首页 新增歌单");
        }
        
    }
}

#pragma mark - VC_EventHandler
- (void)addMusicPlistFile:(FileEntity *)entity {
    //    NSString * title;
    //    if (entity.isFolder) {
    //        title = [NSString stringWithFormat:@"添加整个文件夹《%@》", entity.fileName];
    //    }else{
    //        title = [NSString stringWithFormat:@"添加文件《%@》", entity.fileName];
    //    }
    
    UIColor * color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    NSDictionary * dic = @{
                           @"direction":@(AlertBubbleViewDirectionTop),
                           @"baseView":self.view.vc.navigationController.view,
                           @"borderLineColor":color,
                           @"borderLineWidth":@(1),
                           @"corner":@(10),
                           
                           @"bubbleBgColor":color,
                           @"bgColor":[UIColor clearColor],
                           @"showAroundRect":@(NO),
                           @"showLogInfo":@(NO),
                           };
    
    AlertBubbleView * abView = [[AlertBubbleView alloc] initWithDic:dic];
    
    self.view.musicListTV.center = self.view.vc.navigationController.view.center;
    
    [abView showCustomView:self.view.musicListTV close:^{
        
    }];
    
}

#pragma mark - Interactor_EventHandler
#pragma mark - 搜索
- (void)searchAction:(UISearchBar *)bar {
    [self.view.searchArray removeAllObjects];
    NSString * text = bar.text.lowercaseString;
    for (FileEntity * fileEntity in self.interactor.infoArray) {
        if ([fileEntity.fileName.lowercaseString containsString:text]) {
            [self.view.searchArray addObject:fileEntity];
        }
    }
    [self.view.infoTV reloadData];
}

@end
