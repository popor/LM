//
//  LocalMusicVCPresenter.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import "LocalMusicVCPresenter.h"
#import "LocalMusicVCInteractor.h"

#import "LocalMusicVCRouter.h"
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
        [self initInteractors];
        
    }
    return self;
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

- (void)initInteractors {
    if (!self.interactor) {
        self.interactor = [LocalMusicVCInteractor new];
    }
}

#pragma mark - VC_DataSource
#pragma mark - TV_Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.view.infoTV) {
        return self.interactor.infoArray.count;
    }else{
        return  MpltShare.list.array.count;
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
            [[cell.addBt rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                
                MusicInfoCell  * scell = (MusicInfoCell *)x.superview;
                FileEntity * entity     = (FileEntity *)scell.cellData;
                self.selectFileEntity   = entity;
                
                [self addMusicPlistFile:entity];
            }];
        }
        FileEntity * entity = self.interactor.infoArray[indexPath.row];
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
                //cell.backgroundColor = [UIColor redColor];
            }else{
                cell.titelL.textColor = [UIColor blackColor];
                cell.timeL.textColor  = [UIColor grayColor];
                
                //cell.backgroundColor = [UIColor whiteColor];
            }
        }
        cell.cellData = entity;
        
        return cell;
    }else{
        static NSString * CellID = @"CellMusicList";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        MusicPlayListEntity * list = MpltShare.list.array[indexPath.row];
        cell.textLabel.text = list.name;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.view.infoTV) {
        FileEntity * fileEntity = self.interactor.infoArray[indexPath.row];
        if (fileEntity.isFolder) {
            NSDictionary * dic = @{@"title":fileEntity.fileName, @"itemArray":fileEntity.itemArray};
            [self.view.vc.navigationController pushViewController:[LocalMusicVCRouter vcWithDic:dic] animated:YES];
        }else{
            NSArray * array = @[[MusicPlayItemEntity initWithFileEntity:fileEntity]];
            [MpbShare playTempArray:array at:0];
            
            if (self.lastCell) {
                self.lastCell.titelL.textColor = [UIColor blackColor];
                self.lastCell.timeL.textColor  = [UIColor grayColor];
            }
            {
                MusicInfoCell * cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.titelL.textColor = ColorThemeBlue1;
                cell.timeL.textColor  = ColorThemeBlue1;
                
                self.lastCell = cell;
            }
            
        }
    }else{
        MusicPlayListEntity * list = MpltShare.list.array[indexPath.row];
        if (self.selectFileEntity.isFolder) {
            for (FileEntity * fileEntity in self.selectFileEntity.itemArray) {
                list.array.add([MusicPlayItemEntity initWithFileEntity:fileEntity]);
            }
        }else{
            FileEntity * fileEntity    = self.selectFileEntity;
            list.array.add([MusicPlayItemEntity initWithFileEntity:fileEntity]);
        }
        [MpltShare update];
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

@end
