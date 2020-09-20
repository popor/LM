//
//  SongListDetailVC.m
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.

#import "SongListDetailVC.h"
#import "SongListDetailVCPresenter.h"
#import "SongListDetailVCInteractor.h"

#import "MusicPlayTool.h"
#import <PoporUI/UIViewController+pTapEndEdit.h>

@interface SongListDetailVC () <UISearchBarDelegate>

@property (nonatomic, strong) SongListDetailVCPresenter * present;

@end

@implementation SongListDetailVC
@synthesize infoTV;

@synthesize alertBubbleView;
@synthesize alertBubbleTV;
@synthesize alertBubbleTVColor;

@synthesize searchBar;
@synthesize searchCoverView;
@synthesize searchType;
@synthesize searchTypeOld;
@synthesize searchArray;

@synthesize playbar;
@synthesize listEntity;
@synthesize aimBT;
@synthesize deallocBlock;
@synthesize needUpdateSuperVC;

- (void)dealloc {
    MptShare.nextMusicBlock_SongListDetailVC = nil;
    if (self.deallocBlock) {
        self.deallocBlock(self.needUpdateSuperVC);
    }
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [NSAssistant setVC:self dic:dic];
        self.searchArray = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startMonitorTapEdit];
}

- (void)viewDidDisappear:(BOOL)animated  {
    [super viewDidDisappear:animated];
    
    [self stopMonitorTapEdit];
}


- (void)viewDidLoad {
    [self assembleViper];
    [super viewDidLoad];
    
    if (!self.title) {
        self.title = @"SongListVC";
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
        SongListDetailVCPresenter * present = [SongListDetailVCPresenter new];
        SongListDetailVCInteractor * interactor = [SongListDetailVCInteractor new];
        
        self.present = present;
        [present setMyInteractor:interactor];
        [present setMyView:self];
        
        [self addViews];
        [self startEvent];
    }
}

- (void)addViews {
    self.playbar = [MusicPlayBar share];
    self.infoTV = [self addTVs];
    [self.infoTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-self.playbar.height);
    }];
    __weak typeof(self) weakSelf = self;
    MptShare.nextMusicBlock_SongListDetailVC = ^(void) {
        [weakSelf.present freshTVVisiableCellEvent];
    };
    
    self.searchBar.backgroundColor = PColorTVBG;
    
    self.alertBubbleTVColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.alertBubbleTV = [self addAlertBubbleTV];
    
    [self addAimBTs];
    
    [self.present defaultNcRightItem];
    
#if TARGET_OS_MACCATALYST
    {
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"重命名" style:UIBarButtonItemStylePlain target:self.present action:@selector(listRenameAction)];
        UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self.present action:@selector(listDeleteAction)];
        
        self.navigationItem.leftBarButtonItems = @[item1, item2];
        self.navigationItem.leftItemsSupplementBackButton = YES;
    }
#else
    
#endif
    
    [self addTapEndEditGRAction];
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    [self.present startEvent];
    
}

- (UITableView *)addTVs {
    //UITableView * oneTV = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    UITableView * oneTV = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    oneTV.delegate   = self.present;
    oneTV.dataSource = self.present;
    
    oneTV.allowsMultipleSelectionDuringEditing = YES;
    oneTV.directionalLockEnabled = YES;
    
    oneTV.estimatedRowHeight           = 0;
    oneTV.estimatedSectionHeaderHeight = 0;
    oneTV.estimatedSectionFooterHeight = 0;
    
#if TARGET_OS_MACCATALYST
    oneTV.backgroundColor = PColorTVBG;
    oneTV.separatorColor  = [UIColor grayColor];
    
#else
    
#endif
    
    [self.view addSubview:oneTV];
    
    return oneTV;
}

- (void)addAimBTs {
    {
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
            make.right.mas_equalTo(0);
            //make.size.mas_equalTo(self.aimBT.imageView.image.size);
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.present aimAtCurrentItem:self.aimBT];
    });
}

- (UITableView *)addAlertBubbleTV {
    UITableView * oneTV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 160, SongListDetailVCSortTvCellH * MpViewOrderTitleArray.count) style:UITableViewStylePlain];
    
    oneTV.delegate   = self.present;
    oneTV.dataSource = self.present;
    
    oneTV.allowsMultipleSelectionDuringEditing = YES;
    oneTV.directionalLockEnabled = YES;
    
    oneTV.estimatedRowHeight           = 0;
    oneTV.estimatedSectionHeaderHeight = 0;
    oneTV.estimatedSectionFooterHeight = 0;
    
    oneTV.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    oneTV.backgroundColor = [UIColor clearColor];
    
    oneTV.layer.cornerRadius = 4;
    oneTV.clipsToBounds      = YES;
    oneTV.scrollEnabled      = NO;
    
    oneTV.tintColor = [UIColor whiteColor];
    
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
        [searchBar setBackgroundImage:[UIImage imageFromColor:PRGB16(0XF0F0F0) size:CGSizeMake(1, 1)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault]; //此处使底部线条颜色为红色
        searchBar.tintColor = [UIColor blackColor];
        //searchBar.searchTextField.backgroundColor = PRGB16F(0Xe1e1e1, 1);
        searchBar.searchTextField.backgroundColor = [UIColor lightGrayColor];
        
        searchBar.searchTextField.textColor = [UIColor blackColor];
        
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
        self.infoTV.scrollEnabled = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.searchCoverView.y = CGRectGetMaxY(self.searchBar.frame);
            [self.infoTV addSubview:self.searchCoverView];
            
            [UIView animateWithDuration:duration animations:^{
                self.searchCoverView.backgroundColor = PRGBF(0, 0, 0, 0.25);
                self.searchBar.showsCancelButton = YES;
                
            } completion:^(BOOL finished) {
            }];
        });
        
    }else{
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
        self.searchType = YES;
        [self.present searchAction:searchBar];
        [self.present nilNcRightItem];
    }else{
        [self searchCancelAction];
    }
    self.searchTypeOld = self.isSearchType;
}

- (void)searchCancelAction {
    if (searchBar.text.length == 0) {
        self.searchType = NO;
        [self.present defaultNcRightItem];
        if (self.isSearchTypeOld != self.isSearchType) {
            [self.infoTV reloadData];
        }
    }
}

@end
