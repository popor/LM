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

#import "MusicFolderEntity.h"
#import "MusicPlayBar.h"
#import "MusicConfig.h"

API_AVAILABLE(ios(12.0))
@interface LocalMusicVCPresenter ()

@property (nonatomic, weak  ) id<LocalMusicVCProtocol> view;
@property (nonatomic, strong) LocalMusicVCInteractor * interactor;

@property (nonatomic, weak  ) FileEntity * selectFileEntity;
@property (nonatomic, weak  ) MusicPlayBar * mpb;
@property (nonatomic, weak  ) MusicFolderEntity * mplt;
@property (nonatomic, weak  ) MusicConfigShare  * configShare;
@property (nonatomic, weak  ) MusicInfoCell * lastPlayCell;
@property (nonatomic, weak  ) MusicInfoCell * lastPinYinScrolledCell; // 最后依据拼音顺序滑动的cell

@property (nonatomic, strong) AlertBubbleView * songFolderAbView;


@property (nonatomic        ) UIUserInterfaceStyle userInterfaceStyle;

@property (nonatomic        ) BOOL firstAimAt;
@property (nonatomic        ) NSIndexPath * longPressIP;

@property (nonatomic, weak  ) LocalMusicHeadView * infoTvHead;

@property (nonatomic        ) BOOL userSelectSongMoment;// 用户刚刚点击了歌曲.

@property (nonatomic, copy  ) NSString * lastSearchText;

// rootImage
@property (nonatomic, strong) UIImage * cellLeftImage_downloadN;
@property (nonatomic, strong) UIImage * cellLeftImage_downloadS;
@property (nonatomic, strong) UIImage * cellLeftImage_errorN;
@property (nonatomic, strong) UIImage * cellLeftImage_errorS;
@property (nonatomic, strong) UIImage * cellLeftImage_fileN;
@property (nonatomic, strong) UIImage * cellLeftImage_fileS;

@property (nonatomic, strong) UIImage * cellLeftImage_listN;
@property (nonatomic, strong) UIImage * cellLeftImage_listS;
@property (nonatomic, strong) UIImage * cellLeftImage_favN;
@property (nonatomic, strong) UIImage * cellLeftImage_favS;

// detail
@property (nonatomic, copy  ) UIImage * addImageU;// 目前没有用处
@property (nonatomic, copy  ) UIImage * addImageN;
@property (nonatomic, copy  ) UIImage * addImageS;

@end

@implementation LocalMusicVCPresenter

- (id)init {
    if (self = [super init]) {
        self.mpb = MpbShare;
        self.configShare = [MusicConfigShare share];
        self.userInterfaceStyle = -1;
    }
    return self;
}

- (void)setMyInteractor:(LocalMusicVCInteractor *)interactor {
    self.interactor = interactor;
    
}

- (void)setMyView:(id<LocalMusicVCProtocol>)view {
    self.view = view;
    if (self.view.isRoot) {
        self.cellLeftImage_downloadN  = [UIImage imageNamed:@"songDownload"];
        self.cellLeftImage_errorN     = [UIImage imageNamed:@"songError"];
        self.cellLeftImage_fileN      = [UIImage imageNamed:@"songFile"];
        self.cellLeftImage_listN      = [UIImage imageNamed:@"songList"];
        self.cellLeftImage_favN       = [UIImage imageNamed:@"songFav"];
        
        
        UIColor * color = ColorThemeBlue1;
        self.cellLeftImage_downloadS  = [UIImage imageFromImage:self.cellLeftImage_downloadN changecolor:color];
        self.cellLeftImage_errorN     = [UIImage imageFromImage:self.cellLeftImage_errorN    changecolor:UIColor.redColor];
        self.cellLeftImage_errorS     = [UIImage imageFromImage:self.cellLeftImage_errorN    changecolor:color];
        self.cellLeftImage_fileS      = [UIImage imageFromImage:self.cellLeftImage_fileN     changecolor:color];
        self.cellLeftImage_listS      = [UIImage imageFromImage:self.cellLeftImage_listN     changecolor:color];
        self.cellLeftImage_favS       = [UIImage imageFromImage:self.cellLeftImage_favN      changecolor:color];
    }
    if (self.view.itemArray) {
        self.interactor.localArray = self.view.itemArray;
    }else{
        [self.interactor initData];
    }
    [self.view.infoTV reloadData];
    
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    
    if (self.view.itemArray) {
        [self reloadImageColor];
        
    } else {
        @weakify(self);
        [MRouterC registerURL:MUrl_freshFileData toHandel:^(NSDictionary *routerParameters){
            @strongify(self);
            
            [self freshLocalDataAction];
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self resumeLastPlay_0];
        });
    }
}

// 恢复之前播放记录
- (void)resumeLastPlay_0 {
    NSString * playFileID = self.configShare.config.playFileID;
    for (FileEntity * fe in self.interactor.mplShare.songListArray) {
        if ([fe.fileID isEqualToString:playFileID]) {
            [self resumeLastPlay_1:fe];
            return;
        }
    }
    
    for (FileEntity * fe in self.interactor.localArray) {
        if ([fe.fileID isEqualToString:playFileID]) {
            [self resumeLastPlay_1:fe];
            return;
        }
    }
}

- (void)resumeLastPlay_1:(FileEntity *)fileEntity {
    NSString * playSearchKey = [self.configShare.config.playFileID isEqualToString:fileEntity.fileID] ? self.configShare.config.playSearchKey:@"";
    
    // 有搜索词 跳转到下一层
    if (playSearchKey.length > 0) {
        NSDictionary * dic = @{
            @"title":fileEntity.fileName,
            @"itemArray":fileEntity.itemArray,
            @"folderType":@(fileEntity.fileType),
            @"playFileID":fileEntity.fileID,
            @"playSearchKey":playSearchKey,
            @"autoPlayFilePath":self.configShare.config.playFilePath,
            @"sortType":@(fileEntity.sortType),
        };
        [self.view.vc.navigationController pushViewController:[[LocalMusicVC alloc] initWithDic:dic] animated:YES];
    } else {
        // 没有的 直接在本页播放.
        NSInteger index = -1;
        for (NSInteger i = 0; i<fileEntity.itemArray.count; i++) {
            FileEntity * fe = fileEntity.itemArray[i];
            if ([fe.filePath isEqualToString:self.configShare.config.playFilePath]) {
                index = i;
                break;
            }
        }
        if (index > -1) {
            [self.mpb playSongArray:fileEntity.itemArray
                                 at:index
                           autoPlay:self.configShare.config.autoPlay
                         playFileID:fileEntity.fileID
                          searchKey:@""];
        }
        
    }
}

#pragma mark - VC_DataSource
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.view.infoTV) {
        if (self.view.longPressMenu) {
            self.view.longPressMenu = nil;
        }
    }
}

#pragma mark - TV_Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.view.infoTV) {
        if (self.view.isRoot) {
            return 2;
        } else {
            return 1;
        }
    }
    else if (tableView == self.view.songFolderTV) {
        return 1;
    }
    else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.view.infoTV) {
        if (self.view.isRoot) {
            switch (section) {
                case 0:
                    return self.interactor.mplShare.songListArray.count;
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
    }
    else if (tableView == self.view.songFolderTV) {
        return self.interactor.mplShare.songFolderArray.count;
    }
    
    else{
        return  MAX(self.interactor.mplShare.songFavListEntity.songListArray.count, 1);
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
    }
    else if (tableView == self.view.songFolderTV) {
        return 0.1;
    }
    else{
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
                            [head.sortBT  addTarget:self action:@selector(sortFavFolderAction) forControlEvents:UIControlEventTouchUpInside];
                            [head.setBT   addTarget:self action:@selector(setAction) forControlEvents:UIControlEventTouchUpInside];
                            head;
                        });
                        self.infoTvHead = head;
                    }
                    return head;
                }
                default:
                    return nil;
            }
            
        }else{
            return self.view.searchBar;
        }
    }
    else if (tableView == self.view.songFolderTV) {
        return nil;
    }
    else{
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
    }
    else if (tableView == self.view.songFolderTV) {
        return 0.1;
    }
    else{
        return 0.1;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.infoTV) {
        return MusicInfoCellH;
    }
    else if (tableView == self.view.songFolderTV) {
        return 50;
    }
    else{
        return  50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.infoTV) {
        static NSString * CellID = @"CellFolder";
        MusicInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        if (!cell) {
            //MusicInfoCellType cellType = self.view.isRoot ? MusicInfoCellTypeDefault:MusicInfoCellTypeAdd;
            MusicInfoCellType cellType = MusicInfoCellTypeAdd;
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
    else if (tableView == self.view.songFolderTV) {
        static NSString * CellID = @"CellMusicList";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = App_colorTextN1;
        }
        FileEntity * list   = self.interactor.mplShare.songFolderArray[indexPath.row];
        cell.textLabel.text = list.fileName;
        
        return cell;
    }
    
    else if (tableView == self.view.musicListTV) {
        static NSString * CellID = @"CellMusicList";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = App_colorTextN1;
        }
        FileEntity * list = self.interactor.mplShare.songFavListEntity.songListArray[indexPath.row];
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
            return self.interactor.mplShare.songListArray[indexPath.row];
        case 1:
            return self.interactor.localArray[indexPath.row];
        default:
            return nil;
    }
}

- (void)rootCell:(MusicInfoCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FileEntity * entity = [self rootFE:indexPath];
    
    BOOL colorFull = NO;
    if (entity.itemArray.count == 0) {
        cell.accessoryType       = UITableViewCellAccessoryNone;
        cell.titelL.textColor    = App_colorTextN2;
        cell.subtitleL.textColor = UIColor.grayColor;
        colorFull                = NO;
        
        // text
        cell.titelL.text         = entity.fileName;
        cell.subtitleL.text      = [NSString stringWithFormat:@"%li首", entity.itemArray.count];
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if([self.configShare.config.playFileID isEqualToString:entity.fileID]){
            //cell.rightIV.hidden      = NO;
            cell.titelL.textColor    = ColorThemeBlue1;
            cell.subtitleL.textColor = ColorThemeBlue1;
            colorFull                = YES;
            
            // text
            if (self.configShare.config.playSearchKey.length > 0 && self.interactor.mplShare.currentWeakList && self.mpb.weakLastPlayArray != entity.itemArray) {
                cell.titelL.text = [NSString stringWithFormat:@"%@ %li首 (搜索: %@  %li首)", entity.fileName, entity.itemArray.count, self.configShare.config.playSearchKey, self.interactor.mplShare.currentTempList.count];
                
                NSMutableAttributedString * att = [NSMutableAttributedString new];
                [att addString:[NSString stringWithFormat:@"%@ %li首(", entity.fileName, entity.itemArray.count] font:cell.titelL.font color:cell.subtitleL.textColor];
                [att addString:[NSString stringWithFormat:@"搜索: %@  %li首", self.configShare.config.playSearchKey, self.interactor.mplShare.currentTempList.count] font:cell.titelL.font color:App_colorRed1];
                [att addString:@")" font:cell.titelL.font color:cell.subtitleL.textColor];
                
                cell.titelL.attributedText = att;
            } else {
                cell.titelL.text = [NSString stringWithFormat:@"%@ %li首", entity.fileName, entity.itemArray.count];
            }
            cell.subtitleL.text      = self.configShare.config.playFileNameDeleteExtension;
        }else{
            //cell.rightIV.hidden      = YES;
            cell.titelL.textColor    = App_colorTextN1;
            cell.subtitleL.textColor = UIColor.grayColor;
            colorFull                = NO;
            
            // text
            cell.titelL.text         = entity.fileName;
            cell.subtitleL.text      = [NSString stringWithFormat:@"%li首", entity.itemArray.count];
        }
    }
    
    UIImage * cellLeftImage;
    if (colorFull) {
        if (entity.fileType == FileType_folder) {
            if ([entity.fileName isEqualToString:DownloadFolderName]) {
                cellLeftImage = self.cellLeftImage_downloadS;
            }
            else if ([entity.fileName isEqualToString:ErrorFolderName]) {
                cellLeftImage = self.cellLeftImage_errorS;
            }
            else {
                cellLeftImage = self.cellLeftImage_fileS;
            }
        } else {
            if (indexPath.row == 0) {
                cellLeftImage = self.cellLeftImage_listS;
            } else {
                cellLeftImage = self.cellLeftImage_favS;
            }
        }
    } else {
        if (entity.fileType == FileType_folder) {
            if ([entity.fileName isEqualToString:DownloadFolderName]) {
                cellLeftImage = self.cellLeftImage_downloadN;
            }
            else if ([entity.fileName isEqualToString:ErrorFolderName]) {
                cellLeftImage = self.cellLeftImage_errorN;
            }
            else {
                cellLeftImage = self.cellLeftImage_fileN;
            }
        } else {
            if (indexPath.row == 0) {
                cellLeftImage = self.cellLeftImage_listN;
            } else {
                cellLeftImage = self.cellLeftImage_favN;
            }
        }
    }
    [cell.addBt setImage:cellLeftImage forState:UIControlStateNormal];
    
    cell.cellData = entity;
}

- (void)detailCell:(MusicInfoCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray * songArray = [self currentSongArray];
    FileEntity * entity = songArray[indexPath.row];
    
    if (entity) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.titelL.text = [NSString stringWithFormat:@"%li: %@", indexPath.row+1, entity.songName];
        cell.subtitleL.text  = entity.authorName;
        
        
        if ([entity.filePath isEqualToString:self.mpb.currentItem.filePath]) {
            cell.titelL.textColor = ColorThemeBlue1;
            cell.subtitleL.textColor  = ColorThemeBlue1;
            //cell.rightIV.hidden   = NO;
            [cell.addBt setImage:self.addImageS forState:UIControlStateNormal];
            self.lastPlayCell = cell;
        }else{
            cell.titelL.textColor = App_colorTextN1;
            cell.subtitleL.textColor  = App_colorTextN2;
            //cell.rightIV.hidden   = YES;
            [cell.addBt setImage:self.addImageN forState:UIControlStateNormal];
        }
        
        if ([self isSearchArray]) {
            [self attLable:cell.titelL searchText:self.view.searchBar.text];
            [self attLable:cell.subtitleL searchText:self.view.searchBar.text];
        }
    } else {
        if ([self isSearchArray]) {
            // 搜索的时候, 不会出现这种情况
        } else {
            // 非搜索的时候, 可能出现
            if (self.view.itemArray) {
                // 子页面
                cell.titelL.text = @"请通过Wifi或者iTunes添加MP3文件";
                cell.subtitleL.text  = @"";
                
            } else {
                // 首页
                cell.titelL.text = @"请通过Wifi或者iTunes添加文件夹";
                cell.subtitleL.text  = @"";
                
            }
            
            cell.titelL.textColor = App_colorTextN1;
            cell.subtitleL.textColor  = App_colorTextN2;
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

#pragma mark - tv 移动
// 这个回调实现了以后，就会出现更换位置的按钮，回调本身用来处理更换位置后的数据交换。
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.infoTV) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return NO;
            } else {
                return YES;
            }
        }
        return NO;
    }else{
        return NO;
    }
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    BOOL enable = [self tableView:tableView canMoveRowAtIndexPath:destinationIndexPath];
    if (enable) {
        // 更新 plist部分
        [self.interactor.mplShare.songFavListEntity.songListArray exchangeObjectAtIndex:sourceIndexPath.row-1 withObjectAtIndex:destinationIndexPath.row-1];
        [self.interactor updateSongList];
        
        // 更新本地 record
        [self.interactor.mplShare.songListArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [tableView moveRowAtIndexPath:destinationIndexPath toIndexPath:sourceIndexPath];
        });
    }
}

// 这个回调决定了在当前indexPath的Cell是否可以移动。
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.infoTV) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return NO;
            } else {
                return YES;
            }
        }
        return NO;
    }else{
        return NO;
    }
}

#pragma mark - TV select sectionIndexTitlesForTableView 索引
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (!self.view.isRoot && tableView == self.view.infoTV) {
        //NSLog(@"排序: %@", self.view.searchBar.text);
        if (self.view.searchArray.count > 0) {
            // sortPinYinSearchArray
            if (![self.lastSearchText isEqualToString:self.view.searchBar.text]) {
                self.lastSearchText = self.view.searchBar.text;
                
                [self sortPinYinSearchArray];
            }
            
            if (self.view.sortEntitySearchArray.count > 0) {
                self.view.sortTextSearchArray = [NSMutableArray<NSString *> new];
                for (FileSortEntity * fse in self.view.sortEntitySearchArray) {
                    [self.view.sortTextSearchArray addObject:fse.pinYin];
                }
                return self.view.sortTextSearchArray;
            } else {
                return nil;
            }
        } else {
            if (self.view.sortEntityArray.count > 0) {
                if (!self.view.sortTextArray) {
                    self.view.sortTextArray = [NSMutableArray<NSString *> new];
                    for (FileSortEntity * fse in self.view.sortEntityArray) {
                        [self.view.sortTextArray addObject:fse.pinYin];
                    }
                }
                return self.view.sortTextArray;
            } else {
                return nil;
            }
        }
    } else {
        return nil;
    }
}

// 搜索模式下的拼音排序
- (void)sortPinYinSearchArray {
    NSMutableArray * originEntityArray = self.view.searchArray;
    NSMutableArray<FileSortEntity *> * entityArray = [NSMutableArray<FileSortEntity *> new];
    self.view.sortEntitySearchArray = entityArray;
    NSString * lastText  = @"";
    
    // 先排序歌手
    for (NSInteger index = 0; index <originEntityArray.count; index++) {
        FileEntity * fe = originEntityArray[index];
        if (![fe.pinYinAuthorFirst isEqualToString:lastText]) {
            lastText = fe.pinYinAuthorFirst;
            
            FileSortEntity * fse = [FileSortEntity new];
            fse.row    = index;
            fse.pinYin = lastText;
            
            [entityArray addObject:fse];
        }
    }
        
    // 检查歌手, 在排序歌名
    if (entityArray.count == 1) {
        [entityArray removeAllObjects];
        lastText  = @"";
        for (NSInteger index = 0; index <originEntityArray.count; index++) {
            FileEntity * fe = originEntityArray[index];
            if (![fe.pinYinSongFirst isEqualToString:lastText]) {
                lastText = fe.pinYinSongFirst;
                
                FileSortEntity * fse = [FileSortEntity new];
                fse.row    = index;
                fse.pinYin = [lastText substringToIndex:1];
                
                [entityArray addObject:fse];
            }
        }
        
    }

    
    if (entityArray.count == 1) {
        [entityArray removeAllObjects];
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index {
    FeedbackShakePhone
    NSMutableArray * entityArray;
    if ([self isSearchArray]) {
        entityArray = self.view.sortEntitySearchArray;
    } else {
        entityArray = self.view.sortEntityArray;
    }
    FileSortEntity * fse = entityArray[index];
    
    NSIndexPath * toIP = [NSIndexPath indexPathForRow:fse.row inSection:0];
    [tableView scrollToRowAtIndexPath:toIP atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    MusicInfoCell * cell = [tableView cellForRowAtIndexPath:toIP];
    
    [cell.addBt setTitle:fse.pinYin forState:UIControlStateNormal];
    [cell.addBt setImage:nil        forState:UIControlStateNormal];
    
    if (self.lastPinYinScrolledCell != cell) {
        [self resumeLastPinYinScrolledCellStatus];
        self.lastPinYinScrolledCell = cell;
    }
    
    return fse.row;
}

- (void)resumeLastPinYinScrolledCellStatus {
    if (self.lastPinYinScrolledCell) {
        [self.lastPinYinScrolledCell.addBt setImage:self.addImageN forState:UIControlStateNormal];
        [self.lastPinYinScrolledCell.addBt setTitle:nil            forState:UIControlStateNormal];
        
        self.lastPinYinScrolledCell = nil;
    }
}



#pragma mark - TV select
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.view.longPressMenu) {
        [self.view.longPressMenu setMenuVisible:NO];
        self.view.longPressMenu = nil;
        return;
    }
    if (tableView == self.view.infoTV) {
        if (self.view.isRoot) {
            if (self.view.infoTV.isEditing) {
                return;
            } else {
                [self selectRootCellIP:indexPath];
            }
        } else {
            // 用户点击的话, 不滚动TV.
            self.userSelectSongMoment = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.userSelectSongMoment = NO;
            });
            [self selectDetailCellIP:indexPath autoPlay:YES];
        }
    }
    else if (tableView == self.view.songFolderTV) {
        FeedbackShakePhone
        [self.songFolderAbView closeEvent];
        
        // 物理转移
        FileEntity * originFE;
        for (FileEntity * fe in self.interactor.mplShare.songFolderArray) {
            if ([fe.fileID isEqualToString:self.view.playFileID]) {
                originFE = fe;
                break;
            }
        }
        if (!originFE) {
            AlertToastTitle(@"未能找到原始文件节点");
        }
        
        FileEntity * targetFE = self.interactor.mplShare.songFolderArray[indexPath.row];
        
        NSString * originPath = [NSString stringWithFormat:@"%@/%@", FT_docPath, self.selectFileEntity.filePath];
        NSString * targetPath = [NSString stringWithFormat:@"%@/%@/%@", FT_docPath, targetFE.fileName, self.selectFileEntity.fileName];
        
        if ([NSFileManager isFileExist:targetPath]) {
            [NSFileManager deleteFile:targetPath];
        }
        [NSFileManager moveFile:originPath to:targetPath];
        
        // 更新 self.selectFileEntity
        [self.selectFileEntity updateFileFolder:targetFE.fileName fileType:FileType_file FileName:self.selectFileEntity.fileName];
        
        // 数组转移
        [targetFE.itemArray addObject:self.selectFileEntity];
        [originFE.itemArray removeObject:self.selectFileEntity];
        [self.interactor.localArray removeObject:self.selectFileEntity];
        
        // 刷新 UI
        [self.view.infoTV reloadData];
        [MGJRouter openURL:MUrl_freshRootTV];
        
    }
    else {
        FeedbackShakePhone
        
        FileEntity * list = self.interactor.mplShare.songFavListEntity.songListArray[indexPath.row];
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
        
        NSString * playSearchKey = [self.configShare.config.playFileID isEqualToString:fileEntity.fileID] ? self.configShare.config.playSearchKey:@"";
        NSDictionary * dic = @{
            @"title":fileEntity.fileName,
            @"itemArray":fileEntity.itemArray,
            @"folderType":@(fileEntity.fileType),
            @"playFileID":fileEntity.fileID,
            @"playSearchKey":playSearchKey,
            @"sortType":@(fileEntity.sortType),
        };
        [self.view.vc.navigationController pushViewController:[[LocalMusicVC alloc] initWithDic:dic] animated:YES];
    }
}

- (void)selectDetailCellIP:(NSIndexPath *)indexPath autoPlay:(BOOL)autoPlay {
    FileEntity * fileEntity;
    NSMutableArray<FileEntity> * itemArray;
    
    if ([self isSearchArray]) {
        fileEntity = self.view.searchArray[indexPath.row];
        itemArray  = self.view.searchArray;
        self.view.playSearchKey = self.view.searchBar.text;
    }else{
        fileEntity = self.interactor.localArray[indexPath.row];
        itemArray  = self.interactor.localArray;
        self.view.playSearchKey = @"";
    }
    
    {
        [self.mpb playSongArray:itemArray
                             at:indexPath.row
                       autoPlay:autoPlay
                     playFileID:self.view.playFileID
                      searchKey:self.view.playSearchKey];
        
        if (self.lastPlayCell) {
            self.lastPlayCell.titelL.textColor = App_colorTextN1;
            self.lastPlayCell.subtitleL.textColor  = App_colorTextN2;
            //self.lastPlayCell.rightIV.hidden   = YES;
            
            // 刷新搜索状态
            if ([self isSearchArray]) {
                [self attLable:self.lastPlayCell.titelL searchText:self.view.searchBar.text];
                [self attLable:self.lastPlayCell.subtitleL searchText:self.view.searchBar.text];
            }
        }
        {
            MusicInfoCell * cell = [self.view.infoTV cellForRowAtIndexPath:indexPath];
            cell.titelL.textColor = ColorThemeBlue1;
            cell.subtitleL.textColor  = ColorThemeBlue1;
            //cell.rightIV.hidden   = NO;
            
            self.lastPlayCell = cell;
            
            // 刷新搜索状态
            if ([self isSearchArray]) {
                [self attLable:self.lastPlayCell.titelL searchText:self.view.searchBar.text];
                [self attLable:self.lastPlayCell.subtitleL searchText:self.view.searchBar.text];
            }
        }
        
    }
}

#pragma mark - VC_EventHandler
#pragma mark 打开歌单添加歌曲 列表
- (void)addMusicPlistFile {
    UIColor * color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    color = App_colorBg3;
    
    NSDictionary * dic = @{
        @"direction":@(AlertBubbleViewDirectionTop),
        @"baseView":self.view.vc.navigationController.view,
        @"borderLineColor":[UIColor clearColor],
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
    static UIImage * imageS;
    static UIImage * imageN1;
    static UIImage * imageN2;
    
    static UIImage * imageU;
    
    if (@available(iOS 13, *)) {
        UIUserInterfaceStyle userInterfaceStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
        if (self.userInterfaceStyle != userInterfaceStyle) {
            self.userInterfaceStyle = userInterfaceStyle;
            
            if (!imageN1) {
                UIImage * originImage = [UIImage imageNamed:@"add_gray"];
                
                imageN1 = [UIImage imageFromImage:originImage changecolor:[UIColor blackColor]];
                imageU  = [UIImage imageFromImage:originImage changecolor:[UIColor grayColor]];
                
                imageN2 = [UIImage imageFromImage:originImage changecolor:[UIColor whiteColor]];
                imageS  = [UIImage imageFromImage:originImage changecolor:ColorThemeBlue1];
            }
            
            switch (self.userInterfaceStyle) {
                case UIUserInterfaceStyleLight:
                    self.addImageN = imageN1;
                    self.addImageU = imageU;
                    break;
                    
                case UIUserInterfaceStyleDark:
                    self.addImageN =  imageN2;
                    self.addImageU =  imageU;
                    break;
                    
                default:
                    return;;
            }
            self.addImageS = imageS;
            
            [self.view.infoTV reloadData];
            
        }
    } else {
        if (!imageN1) {
            UIImage * originImage = [UIImage imageNamed:@"add_gray"];
            
            imageN1 = [UIImage imageFromImage:originImage changecolor:[UIColor blackColor]];
            imageU  = [UIImage imageFromImage:originImage changecolor:[UIColor grayColor]];
            imageS  = [UIImage imageFromImage:originImage changecolor:ColorThemeBlue1];
        }
        
        self.addImageN = imageN1;
        self.addImageU = imageU;
        self.addImageS = imageS;
    }
    
    
}

- (void)freshTVVisiableCellEvent {
    [self.view.infoTV reloadRowsAtIndexPaths:[self.view.infoTV indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
    
    if (!self.userSelectSongMoment) {
        [self.view.infoTV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.configShare.config.currentPlayIndexRow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

#pragma mark - Interactor_EventHandler
#pragma mark - 搜索
- (void)searchAction:(UISearchBar *)bar {
    self.view.searchArray = [NSMutableArray<FileEntity> new];
    
    NSString * text = bar.text.lowercaseString; //NSLog(@"搜索 : %@", text);
    if (text.length > 0) {
        for (FileEntity * fileEntity in self.interactor.localArray) {
            if ([fileEntity.fileNameDeleteExtension.lowercaseString containsString:text]) {
                [self.view.searchArray addObject:fileEntity];
            }
        }
    }
    
    if (self.view.searchArray.count == 0 && text.length > 0) {
        AlertToastTitle(@"未找到匹配文件");
    }//NSLogIntegerTitle(self.view.searchArray.count, @"搜索数据");
    
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
    if (self.view.infoTV.isEditing) {
        self.view.infoTV.editing = NO;
        self.infoTvHead.sortBT.selected = NO;
    }
    DMProgressHUD * hud = [DMProgressHUD showLoadingHUDAddedTo:self.view.vc.view];
    __weak typeof(hud) weakHud = hud;
    
    [self.interactor initData];
    [self.view.infoTV reloadData];
    
    [weakHud dismiss];
}

- (void)aimAtCurrentItem:(UIButton * _Nullable)bt {
    if (bt) {
        FeedbackShakePhone
    }
    
    if ([self.configShare.config.playFileID isEqualToString:self.view.playFileID]) {
        if ([self.view.infoTV.dataSource tableView:self.view.infoTV numberOfRowsInSection:0] > self.configShare.config.currentPlayIndexRow) {
            [self.view.infoTV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.configShare.config.currentPlayIndexRow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    } else {
        // 假如有bt, 则是用户点击的, 给提示, 否则不给提示.
        if (bt) {
            AlertToastTitle(@"未播放该歌单");
        }
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

#pragma mark - 排序
- (void)sortFavFolderAction {
    self.infoTvHead.sortBT.selected = !self.infoTvHead.sortBT.isSelected;
    if (self.infoTvHead.sortBT.isSelected) {
        self.view.infoTV.editing = YES;
    } else {
        self.view.infoTV.editing = NO;
    }
    
}

- (void)setAction {
    [MGJRouter openURL:MUrl_appSet];
}

#pragma mark - 长按事件
-(void)longTap:(UILongPressGestureRecognizer *)longRecognizer {
    if (self.view.infoTV.isEditing) {
        return;
    }
    
    if (longRecognizer.state==UIGestureRecognizerStateBegan) {
        FeedbackShakeMedium
        
        self.longPressIP = [self.view.infoTV indexPathForCell:(UITableViewCell *)longRecognizer.view];
        self.selectFileEntity = [self longPressEntity];
        
        [self.view.vc becomeFirstResponder];
        
        self.view.longPressMenu = ({
            UIMenuController *menu = [UIMenuController sharedMenuController];
            
            UIMenuItem *copyItem   = [[UIMenuItem alloc] initWithTitle:@"重命名" action:@selector(cellGrEditFileNameAction)];
            UIMenuItem *resendItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(cellGrDeleteFileAction)];
            UIMenuItem *addItem    = [[UIMenuItem alloc] initWithTitle:@"添加" action:@selector(cellGrAddFolderAction)];
            if (self.view.isRoot) {
                if (self.longPressIP.section == 0 && self.longPressIP.row == 0) { // 假如是全部的话不执行任何操作
                    //UIMenuItem *nullItem   = [[UIMenuItem alloc] initWithTitle:@"默认文件夹" action:@selector(cellGrNullAction_all)];
                    //[menu setMenuItems:[NSArray arrayWithObjects:nullItem,  nil]];
                    
                    [menu setMenuItems:[NSArray arrayWithObjects:addItem, nil]];
                } else {
                    if (self.longPressIP.section == 1) {
                        [menu setMenuItems:[NSArray arrayWithObjects:copyItem, resendItem, addItem, nil]];
                    } else {
                        [menu setMenuItems:[NSArray arrayWithObjects:copyItem, resendItem, addItem, nil]];
                    }
                }
                
            } else {
                UIMenuItem *copy1 = [[UIMenuItem alloc] initWithTitle:@"歌手" action:@selector(cellGrCopySingerNameAction)];
                UIMenuItem *copy2 = [[UIMenuItem alloc] initWithTitle:@"歌曲" action:@selector(cellGrCopySongNameAction)];
                UIMenuItem *copy3 = [[UIMenuItem alloc] initWithTitle:@"文件" action:@selector(cellGrCopyFileNameAction)];
                UIMenuItem *move  = [[UIMenuItem alloc] initWithTitle:@"移动" action:@selector(cellGrMoveAction)];
                
                [menu setMenuItems:[NSArray arrayWithObjects:copyItem, resendItem, copy1, copy2, copy3, move, nil]];
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
            
            [self.interactor updateSongList];
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
            [self.interactor updateSongList];
        }
        AlertToastTitle(@"删除成功");
    }];
    
    [oneAC addAction:cancleAction];
    [oneAC addAction:okAction];
    
    [self.view.vc presentViewController:oneAC animated:YES completion:nil];
}

- (void)deleteFolderAction {
    FileEntity * entity = [self longPressEntity];
   
    NSString * message;
    NSString * okText;
    if (entity.fileType == FileType_folder) {
        message = [NSString stringWithFormat:@"确认删除《%@》吗?\n包含%li个文件", entity.fileName, entity.itemArray.count];
        okText  = @"删除";
    } else {
        message = [NSString stringWithFormat:@"确认移除《%@》吗?", entity.fileName];
        okText  = @"移除";
    }
    
    UIAlertController * oneAC = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:okText style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (entity.fileType == FileType_folder) {
            NSString * path = [NSString stringWithFormat:@"%@/%@", FT_docPath, entity.fileName];
            [NSFileManager deleteFile:path];
            
            [self.interactor.localArray removeObject:entity];
        } else {
            [self.interactor.mplShare.songFavListEntity.songListArray removeObject:entity];
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
    [pasteboard setString:entity.authorName];
    
    AlertToastTitle(@"已复制歌手名称");
}

- (void)cellGrCopySongNameAction {
    FileEntity * entity = [self longPressEntity];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:entity.songName];
    
    AlertToastTitle(@"已复制歌手名称");
}

- (void)cellGrCopyFileNameAction {
    FileEntity * entity = [self longPressEntity];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:entity.fileNameDeleteExtension];
    
    AlertToastTitle(@"已复制文件名称");
}

- (void)cellGrMoveAction {
    UIColor * color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    color = App_colorBg3;
    
    NSDictionary * dic = @{
        @"direction":@(AlertBubbleViewDirectionTop),
        @"baseView":self.view.vc.navigationController.view,
        @"borderLineColor":[UIColor clearColor],
        @"borderLineWidth":@(1),
        @"corner":@(10),
        
        @"bubbleBgColor":color,
        @"bgColor":[UIColor clearColor],
        @"showAroundRect":@(NO),
        @"showLogInfo":@(NO),
    };
    
    AlertBubbleView * abView = [[AlertBubbleView alloc] initWithDic:dic];
    
    self.view.songFolderTV.center = self.view.vc.navigationController.view.center;
    
    [abView showCustomView:self.view.songFolderTV close:^{
        
    }];
    
    self.songFolderAbView = abView;
}

- (FileEntity *)longPressEntity {
    if (self.view.isRoot) {
        switch (self.longPressIP.section) {
            case 0: {
                FileEntity * entity = self.interactor.mplShare.songListArray[self.longPressIP.row];
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
