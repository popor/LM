//
//  LocalMusicVC.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import "LocalMusicVC.h"
#import "LocalMusicVCPresenter.h"
#import "LocalMusicVCInteractor.h"

#import <PoporUI/UIViewController+pTapEndEdit.h>
@interface LocalMusicVC () <UISearchBarDelegate>

@property (nonatomic, strong) LocalMusicVCPresenter * present;

@end

@implementation LocalMusicVC
@synthesize infoTV;
@synthesize musicListTV;
@synthesize playbar;
@synthesize itemArray;

@synthesize searchBar;
@synthesize searchCoverView;
@synthesize searchArray;
@synthesize aimBT;
@synthesize root;
@synthesize folderType;
@synthesize longPressMenu;

@synthesize playFileID;
@synthesize playSearchKey;
@synthesize playFilePath;

- (void)dealloc {
    [MGJRouter openURL:MUrl_freshRootTV];
    MptShare.nextMusicBlock_detailVC = nil;
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [NSAssistant setVC:self dic:dic];
        root = self.itemArray ? NO:YES;
    }
    return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.present reloadImageColor];
        });
    }
}

- (void)viewDidLoad {
    [self assembleViper];
    [super viewDidLoad];
    
    if (!self.title) {
        self.title = @"";
    }
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // 参考: https://www.jianshu.com/p/c244f5930fdf
    if (self.isViewLoaded && !self.view.window) {
        // self.view = nil;//当再次进入此视图中时能够重新调用viewDidLoad方法
        
    }
}

#pragma mark - VCProtocol
- (UIViewController *)vc {
    return self;
}

#pragma mark - viper views
- (void)assembleViper {
    if (!self.present) {
        LocalMusicVCPresenter  * present    = [LocalMusicVCPresenter new];
        LocalMusicVCInteractor * interactor = [LocalMusicVCInteractor new];
        
        self.present = present;
        [present setMyInteractor:interactor];
        [present setMyView:self];
        
        [self addViews];
        [self startEvent];
    }
}

- (void)addViews {
    
    self.playbar     = MpbShare;
    self.infoTV      = [self addTVs];
    self.musicListTV = [self addMusicListTVs];
    
    if (!self.isRoot) {
        self.searchBar.backgroundColor = PColorTVBG;
    }
    
    [self.infoTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        
        if (self.itemArray) { // 子页面
            make.bottom.mas_equalTo(-self.playbar.height);
        } else { // 首页面
            make.bottom.mas_equalTo(0);
        }
    }];
    
    __weak typeof(self) weakSelf = self;
    if (self.itemArray) {
        MptShare.nextMusicBlock_detailVC = ^(void) {
            [weakSelf.present freshTVVisiableCellEvent];
        };
    } else {
        MptShare.nextMusicBlock_rootVC = ^(void) {
            [self.infoTV reloadData];
        };
    }
    
    [self addAimBTs];
    
    [self addTapEndEditGRAction];
    
    if (self.playSearchKey.length > 0) {
        self.searchBar.text = self.playSearchKey;
        
        [self.present searchAction:self.searchBar];
    }
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    [self.present startEvent];
    
}

////-------
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startMonitorTapEdit];
}

- (void)viewDidDisappear:(BOOL)animated  {
    [super viewDidDisappear:animated];
    
    [self stopMonitorTapEdit];
}


#pragma mark - VCProtocol
- (void)setMyPresent:(id)present {
    self.present = present;
}

#pragma mark - views
- (UITableView *)addTVs {
    UITableViewStyle style = self.isRoot ? UITableViewStyleGrouped:UITableViewStylePlain;
    style = UITableViewStyleGrouped;
    UITableView * oneTV = [[UITableView alloc] initWithFrame:self.view.bounds style:style];
    
    oneTV.delegate   = self.present;
    oneTV.dataSource = self.present;
    
    oneTV.allowsMultipleSelectionDuringEditing = NO;
    
    //oneTV.directionalLockEnabled = YES;
    
    oneTV.estimatedRowHeight           = 0;
    oneTV.estimatedSectionHeaderHeight = 0;
    oneTV.estimatedSectionFooterHeight = 0;
    
    oneTV.backgroundColor = App_bgColor4;
    oneTV.separatorColor  = App_separatorColor;
    
    [self.view addSubview:oneTV];
    
    return oneTV;
}

- (UITableView *)addMusicListTVs {
    UITableView * oneTV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 200, 250) style:UITableViewStylePlain];
    
    oneTV.delegate   = self.present;
    oneTV.dataSource = self.present;
    
    oneTV.allowsMultipleSelectionDuringEditing = YES;
    oneTV.directionalLockEnabled = YES;
    
    oneTV.estimatedRowHeight           = 0;
    oneTV.estimatedSectionHeaderHeight = 0;
    oneTV.estimatedSectionFooterHeight = 0;
    
    oneTV.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    oneTV.backgroundColor = [UIColor clearColor];
    
    return oneTV;
}

#pragma mark - 搜索
- (UIView *)searchCoverView {
    if (!searchCoverView) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.infoTV.width, self.infoTV.height)];
        view.backgroundColor = PRGBF(0, 0, 0, 0);
        
        searchCoverView = view;
    }
    return searchCoverView;
}

- (UISearchBar *)searchBar {
    if (!searchBar) {
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, PSCREEN_SIZE.width, 44+10)];
#if TARGET_OS_MACCATALYST
        searchBar.barTintColor = App_bgColor2;
        searchBar.tintColor = [UIColor blackColor];
        searchBar.searchTextField.backgroundColor = [UIColor tertiarySystemBackgroundColor];
        searchBar.searchTextField.textColor       = App_textNColor;
        
#else
        [searchBar setBackgroundImage:[UIImage imageFromColor:[UIColor clearColor] size:CGSizeMake(1, 1)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault]; //此处使底部线条颜色为红色
        searchBar.tintColor   = ColorThemeBlue1;
#endif
        searchBar.placeholder = @"搜索";
        searchBar.delegate    = self;
    }
    return searchBar;
}

- (void)keyboardFrameChanged:(CGRect)rect duration:(CGFloat)duration show:(BOOL)show {
    if (show) {
        if (!self.infoTV.scrollEnabled) {
            return;
        }

        self.infoTV.scrollEnabled = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.searchCoverView.y = CGRectGetMaxY(self.searchBar.frame);
            [self.infoTV addSubview:self.searchCoverView];
            
            [UIView animateWithDuration:duration animations:^{
                self.searchCoverView.backgroundColor = PRGBF(0, 0, 0, 0.25);
                self.searchBar.showsCancelButton = YES;
                
            } completion:nil];
        });
        
    }else{
        if (self.infoTV.scrollEnabled) {
            return;
        }
        
        self.infoTV.scrollEnabled = YES;
        
        [UIView animateWithDuration:duration animations:^{
            self.searchCoverView.backgroundColor = PRGBF(0, 0, 0, 0);
            self.searchBar.showsCancelButton = NO;
            
        } completion:^(BOOL finished) {
            [self.searchCoverView removeFromSuperview];
            [self searchCancelAction];
        }];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self.view becomeFirstResponder];
    
    [self searchCancelAction];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    //NSLog(@"search txt: %@", searchBar.text);
    [searchBar resignFirstResponder];
    [self.view becomeFirstResponder];
   
    if (searchBar.text.length > 0) {
        [self.present searchAction:searchBar];
    }else{
        [self searchCancelAction];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [[self.present class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchAction:) object:nil];
    [self.present performSelector:@selector(searchAction:) withObject:searchBar afterDelay:0.5];
}

- (void)searchCancelAction {
    if (searchBar.text.length == 0) {
        [self.infoTV reloadData];
    }
}

#pragma mark - aimBT
- (void)addAimBTs {
    if (self.isRoot) {
        return;
    }
    self.aimBT = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:LmImageThemeBlue1(@"aim") forState:UIControlStateNormal];
        button.imageView.contentMode = UIViewContentModeCenter;
        
        [self.view addSubview:button];
        
        [button addTarget:self.present action:@selector(aimAtCurrentItem:) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    });
    [self.aimBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.infoTV.mas_bottom).mas_offset(0);
        make.right.mas_equalTo(-5);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self.present aimAtCurrentItem:self.aimBT];
    //    });
}


#pragma mark 处理action事件
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if(action ==@selector(cellGrEditFileNameAction)){
        return YES;
    }
    else if (action==@selector(cellGrNullAction_all)){
        
        return YES;
    }
    else if (action==@selector(cellGrDeleteFileAction)){
        
        return YES;
    }
    else if (action==@selector(cellGrAddFolderAction)){
        
        return YES;
    }
    else if (action==@selector(cellGrCopySingerNameAction)){
        
        return YES;
    }
    else if (action==@selector(cellGrCopySongNameAction)){
        
        return YES;
    }
    else if (action==@selector(cellGrCopyFileNameAction)){
        
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

- (void)cellGrNullAction_all {
    [self.present cellGrNullAction_all];
}

- (void)cellGrEditFileNameAction {
    [self.present cellGrEditFileNameAction];
}

- (void)cellGrDeleteFileAction {
    [self.present cellGrDeleteFileAction];
}

- (void)cellGrAddFolderAction; // 添加文件到歌单
{
    [self.present cellGrAddFolderAction];
}

- (void)cellGrCopySingerNameAction {
    [self.present cellGrCopySingerNameAction];
}
- (void)cellGrCopySongNameAction {
    [self.present cellGrCopySongNameAction];
}
- (void)cellGrCopyFileNameAction {
    [self.present cellGrCopyFileNameAction];
}

#pragma mark 实现成为第一响应者方法
- (BOOL)canBecomeFirstResponder{
    return YES;
}

@end
