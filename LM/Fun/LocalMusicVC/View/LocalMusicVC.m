//
//  LocalMusicVC.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import "LocalMusicVC.h"
#import "LocalMusicVCPresenter.h"
#import "LocalMusicVCRouter.h"

#import <PoporUI/UIViewController+TapEndEdit.h>
@interface LocalMusicVC () <UISearchBarDelegate>

@property (nonatomic, strong) LocalMusicVCPresenter * present;

@end

@implementation LocalMusicVC
@synthesize infoTV;
@synthesize musicListTV;
@synthesize playbar;
@synthesize itemArray;
@synthesize deallocBlock;

@synthesize searchBar;
@synthesize searchCoverView;

- (void)dealloc {
    if (self.deallocBlock) {
        self.deallocBlock();
    }
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [NSAssistant setVC:self dic:dic];
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
    [super viewDidLoad];
    if (!self.title) {
        self.title = @"本地歌曲";
    }
    self.view.backgroundColor = [UIColor whiteColor];
    if (!self.present) {
        [LocalMusicVCRouter setVCPresent:self];
    }
    
    [self addViews];
    
    [self addTapEndEditGRAction];
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

- (void)setMyPresent:(id)present {
    self.present = present;
}

#pragma mark - views
- (void)addViews {
    self.playbar     = MpbShare;
    self.infoTV      = [self addTVs];
    self.musicListTV = [self addMusicListTVs];
    
    if (self.itemArray) {
        self.infoTV.tableHeaderView = self.searchBar;
    }
    
    [self.infoTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-self.playbar.height);
    }];
}

- (UITableView *)addTVs {
    UITableView * oneTV = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    oneTV.delegate   = self.present;
    oneTV.dataSource = self.present;
    
    oneTV.allowsMultipleSelectionDuringEditing = YES;
    oneTV.directionalLockEnabled = YES;
    
    oneTV.estimatedRowHeight           = 0;
    oneTV.estimatedSectionHeaderHeight = 0;
    oneTV.estimatedSectionFooterHeight = 0;
    
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
        view.backgroundColor = RGBA(0, 0, 0, 0);
        
        searchCoverView = view;
    }
    return searchCoverView;
}

- (UISearchBar *)searchBar {
    if (!searchBar) {
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, ScreenSize.width, 44+10)];
        [searchBar setBackgroundImage:[UIImage imageFromColor:[UIColor clearColor] size:CGSizeMake(1, 1)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault]; //此处使底部线条颜色为红色
        searchBar.placeholder = @"搜索";
        searchBar.tintColor   = ColorThemeBlue1;
        searchBar.delegate    = self;
    }
    return searchBar;
}

- (void)keyboardFrameChanged:(CGRect)rect duration:(CGFloat)duration show:(BOOL)show {
    if (show) {
        self.infoTV.scrollEnabled             = NO;
        
        [self.infoTV addSubview:self.searchCoverView];
        
        self.searchCoverView.y = self.searchBar.height;
        
        [UIView animateWithDuration:duration animations:^{
            self.searchCoverView.backgroundColor = RGBA(0, 0, 0, 0.25);
            
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
            [self.navigationController setNavigationBarHidden:YES animated:NO];
            self.searchBar.showsCancelButton = YES;
            
            if (IsVersionLessThan11) {
                [self.infoTV mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(20);
                }];
            }
            
        } completion:^(BOOL finished) {
            
        }];
        
    }else{
        self.infoTV.scrollEnabled             = YES;
        
        [UIView animateWithDuration:duration animations:^{
            self.searchCoverView.backgroundColor = RGBA(0, 0, 0, 0);
            
            self.searchBar.showsCancelButton = NO;
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            
            if (IsVersionLessThan11) {
                [self.infoTV mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(0);
                }];
            }
            
        } completion:^(BOOL finished) {
            [self.searchCoverView removeFromSuperview];
        }];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self.view becomeFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"search txt: %@", searchBar.text);
    [searchBar resignFirstResponder];
    [self.view becomeFirstResponder];
}

@end
