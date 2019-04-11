//
//  SongListDetailVC.m
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.

#import "SongListDetailVC.h"
#import "SongListDetailVCPresenter.h"
#import "SongListDetailVCRouter.h"

#import "MusicPlayTool.h"
#import <PoporUI/UIViewController+TapEndEdit.h>

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
        self.title = @"歌单";
    }
    self.view.backgroundColor = [UIColor whiteColor];
    if (!self.present) {
        [SongListDetailVCRouter setVCPresent:self];
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
    
    self.infoTV.tableHeaderView = self.searchBar;
    
    self.alertBubbleTVColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.alertBubbleTV = [self addAlertBubbleTV];
    
    [self addAimBTs];
    
    [self.present defaultNcRightItem];
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
