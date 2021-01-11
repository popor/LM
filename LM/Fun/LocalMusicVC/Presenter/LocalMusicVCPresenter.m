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

@property (nonatomic        ) BOOL firstAimAt;
@property (nonatomic        ) NSIndexPath * longPressIP;

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
        self.interactor.localArray = self.view.itemArray;
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString * folderName = MpltShare.config.localFolderName;
            NSString * musicName  = MpltShare.config.localMusicName;
            
            for (NSInteger folderIndex = 0; folderIndex<self.interactor.localArray.count; folderIndex++) {
                FileEntity * folderEntity = self.interactor.localArray[folderIndex];
                if ([folderEntity.fileName isEqualToString:folderName]) {
                    for (NSInteger itemIndex = 0; itemIndex < folderEntity.itemArray.count; itemIndex++) {
                        FileEntity * itemEntity = folderEntity.itemArray[itemIndex];
                        
                        if ([itemEntity.fileName isEqualToString:musicName]) {
                            [self.mpb playLocalListArray:folderEntity.itemArray folder:itemEntity.fileName type:McPlayType_local at:itemIndex autoPlay:NO];
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
    if (tableView == self.view.infoTV) {
        if (self.view.isRoot) {
            return 2;
        } else {
            return 1;
        }
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.view.infoTV) {
        if (self.view.isRoot) {
            switch (section) {
                case 0:
                    return self.interactor.recordArray.count;
                case 1:
                    return self.interactor.localArray.count;
                default:
                    return 0;
            }
            
        } else {
            NSMutableArray * array = [self currentSongArray];
            if ([self isSearchArray]) {
                return array.count;
            }else{
                return MAX(array.count, 1);
            }
        }
    }else{
        return  MAX(self.interactor.mplShare.list.songListArray.count, 1);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.view.infoTV) {
        if (self.view.isRoot) {
            switch (section) {
                case 0:
                    return 40;
                case 1:
                    return 0.1;
                default:
                    return 0.1;
            }
            
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
            switch (section) {
                case 0: {
                    LocalMusicHeadView * head = (LocalMusicHeadView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"headerView"];
                    if (!head) {
                        head = ({
                            LocalMusicHeadView * head = [LocalMusicHeadView new];
                            
                            [head.openBT  addTarget:self action:@selector(addFileEvent) forControlEvents:UIControlEventTouchUpInside];
                            [head.freshBT addTarget:self action:@selector(freshLocalDataAction) forControlEvents:UIControlEventTouchUpInside];
                            
                            [head.addBT   addTarget:self action:@selector(addFavFolderAction) forControlEvents:UIControlEventTouchUpInside];
                            head;
                        });
                    }
                    return head;
                }
                default:
                    return nil;
            }
            
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
            return 20;
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
            MusicInfoCellType cellType = self.view.isRoot ? MusicInfoCellTypeDefault:MusicInfoCellTypeAdd;
            cell = [[MusicInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID type:cellType];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (self.view.isRoot) {
                
            } else {
                @weakify(self);
                @weakify(cell);
                [[cell.addBt rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                    @strongify(self);
                    @strongify(cell);
                    FeedbackShakePhone
                    
                    FileEntity * entity = (FileEntity *)cell.cellData;
                    self.selectFileEntity = entity;
                    [self addMusicPlistFile];
                }];
            }
            // 长按事件
            [cell addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)]];
            
        }
        
        if (self.view.isRoot) {
            [self rootCell:cell cellForRowAtIndexPath:indexPath];
        } else {
            [self detailCell:cell cellForRowAtIndexPath:indexPath];
        }
        
        return cell;
    }
    
    else if (tableView == self.view.musicListTV) {
        static NSString * CellID = @"CellMusicList";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        FileEntity * list = self.interactor.mplShare.list.songListArray[indexPath.row];
        if (list) {
            cell.textLabel.text = list.fileName;
        } else {
            cell.textLabel.text = @"请在首页 新增歌单";
        }
        
        return cell;
    }
    
    else {
        return nil;
    }
}

- (FileEntity *)rootFE:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return self.interactor.recordArray[indexPath.row];
        case 1:
            return self.interactor.localArray[indexPath.row];
        default:
            return nil;
    }
}

- (void)rootCell:(MusicInfoCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FileEntity * entity = [self rootFE:indexPath];
    
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
    
    cell.cellData = entity;
}

- (void)detailCell:(MusicInfoCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray * songArray = [self currentSongArray];
    FileEntity * entity = songArray[indexPath.row];
    
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
            
            // if (entity == self.interactor.allFileEntity) {
            //     cell.addBt.hidden = YES;
            // } else {
            //     cell.addBt.hidden = NO;
            // }
            
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
            
            if ([self isSearchArray]) {
                [self attLable:cell.titelL searchText:self.view.searchBar.text];
                [self attLable:cell.timeL searchText:self.view.searchBar.text];
            }
        }
    } else {
        if ([self isSearchArray]) {
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
}


- (BOOL)isSearchArray {
    if (self.view.searchArray.count > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (NSMutableArray *)currentSongArray {
    if (self.view.searchArray.count > 0) {
        return self.view.searchArray;
    } else {
        return self.interactor.localArray;
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
    if (self.view.longPressMenu) {
        [self.view.longPressMenu setMenuVisible:NO];
        self.view.longPressMenu = nil;
        return;
    }
    if (tableView == self.view.infoTV) {
        if (self.view.isRoot) {
            [self selectRootCellIP:indexPath];
        } else {
            [self selectDetailCellIP:indexPath];
        }
    }
    
    else {
        FeedbackShakePhone
        
        FileEntity * list = self.interactor.mplShare.list.songListArray[indexPath.row];
        if (list) {
            if (!list.itemArray) {
                list.itemArray = [NSMutableArray<FileEntity> new];
            }
            if (self.selectFileEntity.isFolder) {
                [list.itemArray addObjectsFromArray:self.selectFileEntity.itemArray];
            }else{
                [list.itemArray addObject:self.selectFileEntity];
            }
            [self.interactor updateSongList];
            
            [MGJRouter openURL:MUrl_freshRootTV];
            
            AlertToastTitle(@"增加成功");
        } else {
            AlertToastTitle(@"请在首页 新增歌单");
        }
        
    }
}

- (void)selectRootCellIP:(NSIndexPath *)indexPath {
    FileEntity * fileEntity = [self rootFE:indexPath];
    if (fileEntity.itemArray.count > 0) {
        NSDictionary * dic = @{
            @"title":fileEntity.fileName,
            @"itemArray":fileEntity.itemArray,
            @"folderType":@(fileEntity.fileType),
        };
        [self.view.vc.navigationController pushViewController:[[LocalMusicVC alloc] initWithDic:dic] animated:YES];
    }
}

- (void)selectDetailCellIP:(NSIndexPath *)indexPath {
    FileEntity * fileEntity;
    NSMutableArray<FileEntity> * itemArray;
    McPlayType playType;
    if ([self isSearchArray]) {
        fileEntity = self.view.searchArray[indexPath.row];
        itemArray  = self.view.searchArray;
        playType   = McPlayType_searchLocal;
    }else{
        fileEntity = self.interactor.localArray[indexPath.row];
        itemArray  = self.interactor.localArray;
        playType   = McPlayType_local;
    }
    
    {
        [self.mpb playLocalListArray:itemArray folder:fileEntity.folderName type:playType at:indexPath.row autoPlay:YES];
        
        if (self.lastCell) {
            self.lastCell.titelL.textColor = App_textNColor;
            self.lastCell.timeL.textColor  = App_textNColor2;
            self.lastCell.rightIV.hidden   = YES;
            
            // 刷新搜索状态
            if ([self isSearchArray]) {
                [self attLable:self.lastCell.titelL searchText:self.view.searchBar.text];
                [self attLable:self.lastCell.timeL searchText:self.view.searchBar.text];
            }
        }
        {
            MusicInfoCell * cell = [self.view.infoTV cellForRowAtIndexPath:indexPath];
            cell.titelL.textColor = ColorThemeBlue1;
            cell.timeL.textColor  = ColorThemeBlue1;
            cell.rightIV.hidden   = NO;
            
            self.lastCell = cell;
            
            // 刷新搜索状态
            if ([self isSearchArray]) {
                [self attLable:self.lastCell.titelL searchText:self.view.searchBar.text];
                [self attLable:self.lastCell.timeL searchText:self.view.searchBar.text];
            }
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
    [self.view.infoTV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.mplt.config.currentPlayIndexRow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

#pragma mark - Interactor_EventHandler
#pragma mark - 搜索
- (void)searchAction:(UISearchBar *)bar {
    [self.view.searchArray removeAllObjects];
    NSString * text = bar.text.lowercaseString;
    //NSLog(@"搜索 : %@", text);
    for (FileEntity * fileEntity in self.interactor.localArray) {
        if ([fileEntity.fileNameDeleteExtension.lowercaseString containsString:text]) {
            //NSLog(@"fileName: %@", fileEntity.fileNameDeleteExtension.lowercaseString);
            [self.view.searchArray addObject:fileEntity];
        }
    }
    //NSLogIntegerTitle(self.view.searchArray.count, @"搜索数据");
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
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {}];
    } else {
        // Fallback on earlier versions
    }
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

- (void)aimAtCurrentItem:(UIButton *)bt {
    FeedbackShakePhone
    
    if ([self.mplt.config.localFolderName isEqualToString:self.view.vc.title]) {
        if ([self.view.infoTV.dataSource tableView:self.view.infoTV numberOfRowsInSection:0] > self.mpb.mplt.config.currentPlayIndexRow) {
            [self.view.infoTV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.mpb.mplt.config.currentPlayIndexRow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    } else {
        AlertToastTitle(@"未播放该歌单");
    }
}

#pragma mark - 新增Folder
- (void)addFavFolderAction {
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
            [self.interactor addListName:nameTF.text];
            
            [self.interactor freshFavFolderEvent];
            [self.view.infoTV reloadData];
        }
    }];
    
    [oneAC addAction:cancleAction];
    [oneAC addAction:changeAction];
    
    [self.view.vc presentViewController:oneAC animated:YES completion:nil];
}

#pragma mark - 长按事件

-(void)longTap:(UILongPressGestureRecognizer *)longRecognizer {
    if (longRecognizer.state==UIGestureRecognizerStateBegan) {
        FeedbackShakeMedium
        
        self.longPressIP = [self.view.infoTV indexPathForCell:(UITableViewCell *)longRecognizer.view];
        self.selectFileEntity = [self longPressEntity];
        
        [self.view.vc becomeFirstResponder];
        
        self.view.longPressMenu = ({
            UIMenuController *menu = [UIMenuController sharedMenuController];
            
            UIMenuItem *copyItem   = [[UIMenuItem alloc] initWithTitle:@"修改" action:@selector(cellGrEditFileNameAction)];
            UIMenuItem *resendItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(cellGrDeleteFileAction)];
            if (self.view.isRoot) {
                if (self.longPressIP.section == 0 && self.longPressIP.row == 0) { // 假如是全部的话不执行任何操作
                    UIMenuItem *nullItem   = [[UIMenuItem alloc] initWithTitle:@"默认文件夹" action:@selector(cellGrNullAction_all)];
                    [menu setMenuItems:[NSArray arrayWithObjects:nullItem, nil]];
                } else {
                    UIMenuItem *addItem = [[UIMenuItem alloc] initWithTitle:@"添加" action:@selector(cellGrAddFolderAction)];
                    if (self.longPressIP.section == 1) {
                        [menu setMenuItems:[NSArray arrayWithObjects:copyItem, resendItem, addItem, nil]];
                    } else {
                        [menu setMenuItems:[NSArray arrayWithObjects:copyItem, resendItem, nil]];
                    }
                }
                
            } else {
                UIMenuItem *copy1 = [[UIMenuItem alloc] initWithTitle:@"歌手" action:@selector(cellGrCopySingerNameAction)];
                UIMenuItem *copy2 = [[UIMenuItem alloc] initWithTitle:@"歌曲" action:@selector(cellGrCopySongNameAction)];
                UIMenuItem *copy3 = [[UIMenuItem alloc] initWithTitle:@"文件" action:@selector(cellGrCopyFileNameAction)];
                
                [menu setMenuItems:[NSArray arrayWithObjects:copyItem, resendItem, copy1, copy2, copy3, nil]];
            }
            
            [menu setTargetRect:CGRectOffset(longRecognizer.view.frame, 0, 10) inView:self.view.infoTV];
            
            [menu setMenuVisible:YES animated:YES];
            
            menu;
        });
    }
}

#pragma mark method
- (void)cellGrNullAction_all{
    //AlertToastTitle(@"默认歌单不能修改和删除");
}

- (void)cellGrEditFileNameAction {
    FileEntity * entity = [self longPressEntity];
    
    if (entity.fileNameDeleteExtension.length > 0) {
        // 音乐
        [self editFileAction];
    } else {
        // 文件夹
        [self editFolderAction];
    }
}

- (void)editFileAction {
    FileEntity * entity = [self longPressEntity];
    
    UIAlertController * oneAC = [UIAlertController alertControllerWithTitle:@"修改文件名称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [oneAC addTextFieldWithConfigurationHandler:^(UITextField *textField){
        
        textField.placeholder = entity.fileName;
        textField.text        = entity.fileName;
    }];
    
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * changeAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField * nameTF = oneAC.textFields[0];
        //NSLog(@"更新 name: %@", nameTF.text);
        if (nameTF.text.length > 0) {
            NSString * path0 = [NSString stringWithFormat:@"%@/%@", FT_docPath, entity.filePath];
            NSString * path1 = [NSString stringWithFormat:@"%@/%@/%@", FT_docPath, entity.folderName, nameTF.text];
            [NSFileManager moveFile:path0 to:path1];
            
            [entity updateFileFolder:entity.folderName fileType:FileType_file FileName:nameTF.text];
            
//            if (self.) {
//                <#statements#>
//            }
            [self.view.infoTV reloadData];
        }
    }];
    
    [oneAC addAction:cancleAction];
    [oneAC addAction:changeAction];
    
    [self.view.vc presentViewController:oneAC animated:YES completion:nil];
}

- (void)editFolderAction {
    FileEntity * entity = [self longPressEntity];
    
    UIAlertController * oneAC = [UIAlertController alertControllerWithTitle:@"修改文件夹名称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [oneAC addTextFieldWithConfigurationHandler:^(UITextField *textField){
        
        textField.placeholder = entity.fileName;
        textField.text        = entity.fileName;
    }];
    
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * changeAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField * nameTF = oneAC.textFields[0];
        //NSLog(@"更新 name: %@", nameTF.text);
        if (nameTF.text.length > 0) {
            if (entity.fileType == FileType_folder) {
                NSString * path0 = [NSString stringWithFormat:@"%@/%@", FT_docPath, entity.fileName];
                NSString * path1 = [NSString stringWithFormat:@"%@/%@", FT_docPath, nameTF.text];
                [NSFileManager moveFile:path0 to:path1];
                
                [entity updateFileFolder:entity.folderName fileType:FileType_folder FileName:nameTF.text];
                
                for (FileEntity * fe in entity.itemArray) {
                    [fe updateFileFolder:entity.fileName fileType:FileType_file FileName:fe.fileName];
                }
            } else {
                entity.fileName = nameTF.text;
                [self.interactor updateSongList];
            }
            [self.view.infoTV reloadData];
        }
    }];
    
    [oneAC addAction:cancleAction];
    [oneAC addAction:changeAction];
    
    [self.view.vc presentViewController:oneAC animated:YES completion:nil];
}

- (void)cellGrDeleteFileAction {
    FileEntity * entity = [self longPressEntity];
    
    //NSLog(@"entity: %@", entity.fileNameDeleteExtension);
    if (entity.fileNameDeleteExtension.length > 0) {
        // 音乐
        [self deleteFileAction];
    } else {
        // 文件夹
        [self deleteFolderAction];
    }
}

- (void)deleteFileAction {
    FileEntity * entity = [self longPressEntity];
    
    NSString * message;
    NSString * okText;
    if (self.view.folderType == FileType_folder) {
        message = [NSString stringWithFormat:@"确认删除'%@'吗?", entity.fileNameDeleteExtension];
        okText  = @"删除";
    } else {
        message = [NSString stringWithFormat:@"确认从《%@》移除'%@'吗?", self.view.vc.title, entity.fileNameDeleteExtension];
        okText  = @"移除";
    }
    UIAlertController * oneAC = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:okText style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        if (self.view.folderType == FileType_folder) {
            NSString * path = [NSString stringWithFormat:@"%@/%@", FT_docPath, entity.filePath];
            [NSFileManager deleteFile:path];
            
            [self.interactor.localArray removeObject:entity];
            [self.view.searchArray removeObject:entity];
            [self.view.infoTV reloadData];
        } else if (self.view.folderType == FileType_virtualFolder) {
            // 仅仅是文件夹移除
            [self.interactor.localArray removeObject:entity];
            [self.view.searchArray removeObject:entity];
            [self.view.infoTV reloadData];
        }
        AlertToastTitle(@"删除成功");
    }];
    
    [oneAC addAction:cancleAction];
    [oneAC addAction:okAction];
    
    [self.view.vc presentViewController:oneAC animated:YES completion:nil];
}

- (void)deleteFolderAction {
    FileEntity * entity = [self longPressEntity];
    
    UIAlertController * oneAC = [UIAlertController alertControllerWithTitle:@"提醒" message:[NSString stringWithFormat:@"确认删除《%@》吗?\n包含%li个文件", entity.fileName, entity.itemArray.count] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (entity.fileType == FileType_folder) {
            NSString * path = [NSString stringWithFormat:@"%@/%@", FT_docPath, entity.fileName];
            [NSFileManager deleteFile:path];
            
            [self.interactor.localArray removeObject:entity];
        } else {
            [self.interactor.mplShare.list.songListArray removeObject:entity];
            [self.interactor updateSongList];
            [self.interactor freshFavFolderEvent];
        }
        
        AlertToastTitle(@"删除成功");
        [self.view.infoTV reloadData];
    }];
    
    [oneAC addAction:cancleAction];
    [oneAC addAction:okAction];
    
    [self.view.vc presentViewController:oneAC animated:YES completion:nil];
}

- (void)cellGrAddFolderAction {// 添加文件到歌单
    [self addMusicPlistFile];
}

- (void)cellGrCopySingerNameAction {
    FileEntity * entity = [self longPressEntity];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:entity.musicAuthor];
    
    AlertToastTitle(@"已复制歌手名称");
}

- (void)cellGrCopySongNameAction {
    FileEntity * entity = [self longPressEntity];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:entity.musicName];
    
    AlertToastTitle(@"已复制歌手名称");
}

- (void)cellGrCopyFileNameAction {
    FileEntity * entity = [self longPressEntity];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:entity.fileNameDeleteExtension];
    
    AlertToastTitle(@"已复制文件名称");
}

- (FileEntity *)longPressEntity {
    if (self.view.isRoot) {
        switch (self.longPressIP.section) {
            case 0: {
                FileEntity * entity = self.interactor.recordArray[self.longPressIP.row];
                return entity;
            }
            case 1: {
                FileEntity * entity = self.interactor.localArray[self.longPressIP.row];
                return entity;
            }
            default:
                return nil;
        }
    } else {
        NSMutableArray * songArray = [self currentSongArray];
        FileEntity * entity = songArray[self.longPressIP.row];
        return entity;
    }
}

@end
