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

API_AVAILABLE(ios(12.0))
@interface LocalMusicVCPresenter ()

@property (nonatomic, weak  ) id<LocalMusicVCProtocol> view;
@property (nonatomic, strong) LocalMusicVCInteractor * interactor;

@property (nonatomic, weak  ) FileEntity * selectFileEntity;
@property (nonatomic, weak  ) MusicPlayBar * mpb;
@property (nonatomic, weak  ) MusicPlayListTool * mplt;
@property (nonatomic, weak  ) MusicInfoCell * lastCell;

@property (nonatomic, copy  ) UIImage * addImageGray;
@property (nonatomic, copy  ) UIImage * addImageBlack;

@property (nonatomic        ) UIUserInterfaceStyle userInterfaceStyle;

@end

@implementation LocalMusicVCPresenter

- (id)init {
    if (self = [super init]) {
        self.mpb = MpbShare;
        self.mplt = MpltShare;
        self.userInterfaceStyle = -1;
        [self reloadImageColor];
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
    
    [self addMgjrouter];
}

- (void)addMgjrouter {
    // 子页面不需要
    if (self.view.itemArray) {
        return;
    }
    
    @weakify(self);
    [MRouterC registerURL:MUrl_resumePlayItem_local toHandel:^(NSDictionary *routerParameters){
        @strongify(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString * folderName = MpltShare.config.localFolderName;
            NSString * musicName  = MpltShare.config.localMusicName;
            
            for (NSInteger folderIndex = 0; folderIndex<self.interactor.infoArray.count; folderIndex++) {
                FileEntity * folderEntity = self.interactor.infoArray[folderIndex];
                if ([folderEntity.folderName isEqualToString:folderName]) {
                    for (NSInteger itemIndex = 0; itemIndex < folderEntity.itemArray.count; itemIndex++) {
                        FileEntity * itemEntity = folderEntity.itemArray[itemIndex];
                        
                        if ([itemEntity.fileName isEqualToString:musicName]) {
                            [self.mpb playLocalListArray:folderEntity.itemArray folder:itemEntity.fileName type:McPlayType_local at:itemIndex];
                            break;
                        }
                    }
                    break;
                }
            }
            
            
        });
    }];
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
            return MAX(self.interactor.infoArray.count, 1);
        }
        
    }else{
        return  MAX(MpltShare.list.songListArray.count, 1);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.view.infoTV) {
        if (self.view.isRoot) {
            return 40;
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
            LocalMusicHeadView * head = (LocalMusicHeadView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"headerView"];
            if (!head) {
                head = ({
                    LocalMusicHeadView * head = [LocalMusicHeadView new];
                    
                    [head.openBT  addTarget:self action:@selector(addFileEvent) forControlEvents:UIControlEventTouchUpInside];
                    [head.freshBT addTarget:self action:@selector(freshLocalDataAction) forControlEvents:UIControlEventTouchUpInside];
                    
                    head;
                });
            }
            return head;
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.infoTV) {
        return MusicInfoCellH;
    }else{
        return  50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.infoTV) {
        static NSString * CellID = @"CellFolder";
        MusicInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        if (!cell) {
            cell = [[MusicInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID type:MusicInfoCellTypeAdd];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            @weakify(self);
            @weakify(cell);
            [[cell.addBt rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                @strongify(cell);
                
                FileEntity * entity = (FileEntity *)cell.cellData;
                self.selectFileEntity = entity;
                if (entity.isFolder) {
                    if (entity.itemArray.count != 0) {
                        [self addMusicPlistFile];
                    }
                } else {
                    [self addMusicPlistFile];
                }
            }];
        }
        
        FileEntity * entity;
        if (self.view.isSearchType) {
            entity = self.view.searchArray[indexPath.row];
        } else {
            entity = self.interactor.infoArray[indexPath.row];
        }
        if (entity) {
            if (entity.isFolder) {
                cell.titelL.text = entity.fileName;
                cell.timeL.text  = [NSString stringWithFormat:@"%li首", entity.itemArray.count];
                
                if (self.mplt.config.playType == McPlayType_songList
                    || self.mplt.config.playType == McPlayType_searchSongList) {
                    
                    cell.rightIV.hidden   = YES;
                    cell.titelL.textColor = App_textNColor;
                } else {
                    
                    if (entity.itemArray.count == 0) {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        cell.titelL.textColor = App_textNColor2;
                        [cell.addBt setImage:self.addImageGray forState:UIControlStateNormal];
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        //cell.titelL.textColor = App_textNColor;
                        [cell.addBt setImage:self.addImageBlack forState:UIControlStateNormal];
                        
                        if([self.mplt.config.localFolderName isEqualToString:entity.fileName]){
                            cell.rightIV.hidden = NO;
                            cell.titelL.textColor = ColorThemeBlue1;
                        }else{
                            cell.rightIV.hidden = YES;
                            cell.titelL.textColor = App_textNColor;
                        }
                        
                    }
                    
                }
                
                
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                cell.titelL.text = [NSString stringWithFormat:@"%li: %@", indexPath.row+1, entity.musicName];
                cell.timeL.text  = entity.musicAuthor;
                [cell.addBt setImage:self.addImageBlack forState:UIControlStateNormal];
                
                if ([entity.filePath isEqualToString:self.mpb.currentItem.filePath]) {
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
            }
        } else {
            if (self.view.isSearchType) {
                // 搜索的时候, 不会出现这种情况
            } else {
                // 非搜索的时候, 可能出现
                if (self.view.itemArray) {
                    // 子页面
                    cell.titelL.text = @"请通过Wifi或者iTunes添加MP3文件";
                    cell.timeL.text  = @"";
                    
                } else {
                    // 首页
                    cell.titelL.text = @"请通过Wifi或者iTunes添加文件夹";
                    cell.timeL.text  = @"";
                    
                }
                
                cell.titelL.textColor = App_textNColor;
                cell.timeL.textColor  = App_textNColor2;
            }
        }
        
        cell.cellData = entity;
        
        return cell;
    }
    
    else {
        static NSString * CellID = @"CellMusicList";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        MusicPlayListEntity * list = MpltShare.list.songListArray[indexPath.row];
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
        NSMutableArray<FileEntity> * itemArray;
        McPlayType playType;
        if (self.view.isSearchType) {
            fileEntity = self.view.searchArray[indexPath.row];
            itemArray  = self.view.searchArray;
            playType   = McPlayType_searchLocal;
        }else{
            fileEntity = self.interactor.infoArray[indexPath.row];
            itemArray  = self.interactor.infoArray;
            playType   = McPlayType_local;
        }
        if (fileEntity) {
            if (fileEntity.isFolder) {
                if (fileEntity.itemArray.count > 0) {
                    NSDictionary * dic = @{@"title":fileEntity.fileName, @"itemArray":fileEntity.itemArray};
                    [self.view.vc.navigationController pushViewController:[[LocalMusicVC alloc] initWithDic:dic] animated:YES];
                }
            } else {
                [self.mpb playLocalListArray:itemArray folder:fileEntity.folderName type:playType at:indexPath.row];
                
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
                
            }
        } else {
            [self addFileEvent];
        }
    }
    
    else {
        MusicPlayListEntity * list = MpltShare.list.songListArray[indexPath.row];
        if (list) {
            if (self.selectFileEntity.isFolder) {
                for (FileEntity * fileEntity in self.selectFileEntity.itemArray) {
                    FileEntity * nEntity = [[FileEntity alloc] initWithDictionary:[fileEntity toDictionary] error:nil];
                    nEntity.index = list.recoredNum++;
                    list.itemArray.add(nEntity);
                }
            }else{
                FileEntity * fileEntity = self.selectFileEntity;
                FileEntity * nEntity = [[FileEntity alloc] initWithDictionary:[fileEntity toDictionary] error:nil];
                nEntity.index = list.recoredNum++;
                list.itemArray.add(nEntity);
            }
            [MpltShare updateSongList];
            
            [MGJRouter openURL:MUrl_freshRootTV];
            
            AlertToastTitle(@"增加成功");
        } else {
            AlertToastTitle(@"请在首页 新增歌单");
        }
        
    }
}

#pragma mark - VC_EventHandler
- (void)addMusicPlistFile {
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

- (void)reloadImageColor {
    static UIImage * imageN1;
    static UIImage * imageN2;
    static UIImage * imageS1;
    
    if (@available(iOS 13, *)) {
        UIUserInterfaceStyle userInterfaceStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
        if (self.userInterfaceStyle != userInterfaceStyle) {
            self.userInterfaceStyle = userInterfaceStyle;
            
            if (!imageN1) {
                UIImage * originImage = [UIImage imageNamed:@"add_gray"];
                
                imageN1 = [UIImage imageFromImage:originImage changecolor:[UIColor blackColor]];
                imageS1 = [UIImage imageFromImage:originImage changecolor:[UIColor grayColor]];
                
                imageN2 = [UIImage imageFromImage:originImage changecolor:[UIColor whiteColor]];
            }
            
            switch (self.userInterfaceStyle) {
                case UIUserInterfaceStyleLight:
                    self.addImageBlack = imageN1;
                    self.addImageGray  = imageS1;
                    break;
                    
                case UIUserInterfaceStyleDark:
                    self.addImageBlack =  imageN2;
                    self.addImageGray  =  imageN2;
                    break;
                    
                default:
                    return;;
            }
            [self.view.infoTV reloadData];
            
        }
    } else {
        if (!imageN1) {
            UIImage * originImage = [UIImage imageNamed:@"add_gray"];
            
            imageN1 = [UIImage imageFromImage:originImage changecolor:[UIColor blackColor]];
            imageS1 = [UIImage imageFromImage:originImage changecolor:[UIColor grayColor]];
        }
        
        self.addImageBlack = imageN1;
        self.addImageGray  = imageS1;
    }
    
    
}

- (void)freshTVVisiableCellEvent {
    [self.view.infoTV reloadRowsAtIndexPaths:[self.view.infoTV indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
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

- (void)addFileEvent {
#if TARGET_OS_MACCATALYST
    [self openDocFolderAction];
#else
    [self openWifiVC];
#endif
}

- (void)openDocFolderAction {
    //NSURL * url = [NSURL fileURLWithPath:@"file:///Users/popor/Desktop/demo/"];
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@/%@", FT_docPath, MusicFolderName]];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {}];
}

- (void)openWifiVC {
    [MGJRouter openURL:MUrl_wifiAddFileVC];
}

- (void)freshLocalDataAction {
    DMProgressHUD * hud = [DMProgressHUD showLoadingHUDAddedTo:self.view.vc.view];
    __weak typeof(hud) weakHud = hud;
    
    [self.interactor initData];
    [self.view.infoTV reloadData];
    
    [weakHud dismiss];
}

@end
