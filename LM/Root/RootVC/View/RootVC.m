//
//  RootVC.m
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import "RootVC.h"
#import "RootVCPresenter.h"
#import "RootVCInteractor.h"

#import "UINavigationController+Jch.h"

@interface RootVC ()

@property (nonatomic, strong) RootVCPresenter * present;

@end

@implementation RootVC
@synthesize playbar;
@synthesize titleArray;
@synthesize tvArray;
//@synthesize infoTV;
//@synthesize localTV;
@synthesize alertBubbleView;
@synthesize alertBubbleTV;
@synthesize alertBubbleTVColor;
@synthesize segmentView;
@synthesize tvSV;
@synthesize songListVC;
@synthesize localMusicVC;


- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [NSAssistant setVC:self dic:dic];
    }
    return self;
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
        RootVCPresenter * present = [RootVCPresenter new];
        RootVCInteractor * interactor = [RootVCInteractor new];
        
        self.present = present;
        [present setMyInteractor:interactor];
        [present setMyView:self];
        
        [self addViews];
        [self startEvent];
    }
}

// -----------------------------------------------------------------------------
#pragma mark - views
- (void)addViews {
    [self addPlayboard];
//
//    self.infoTV = [self addTVs];
//
//    self.view.backgroundColor = self.infoTV.backgroundColor;
//    //self.navigationController.view.backgroundColor = self.infoTV.backgroundColor;
//
//    [self.infoTV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(0);
//        make.left.mas_equalTo(0);
//        make.right.mas_equalTo(0);
//        make.bottom.mas_equalTo(-self.playbar.height);
//    }];
    
    {
        self.alertBubbleTVColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.alertBubbleTV = [self addAlertBubbleTV];
    }
    {
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self.present action:@selector(showTVAlertAction:event:)];
        self.navigationItem.rightBarButtonItems = @[item1];
    }
    {
        self.navigationController.navigationBar.tintColor = ColorThemeBlue1;
    }
    
    {
        [self addHeadSegmentViews];
        self.navigationItem.titleView = self.segmentView;
        
        [self addSVs];
        
        self.segmentView.weakLinkSV = self.tvSV;
        self.segmentView.weakLinkSV.delegate = self.segmentView;
    }
    
#if TARGET_OS_MACCATALYST
    // mac 模式下需要监听用户缩放frame
    @weakify(self);
    [RACObserve(self.navigationController.view, frame) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        NSLog(@"刷新frame");
        [self.playbar updateProgressSectionFrame];
        
        
        // [self.infoTV reloadData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tvSV.contentSize = CGSizeMake(ceil(self.tvSV.width +1)*2, self.tvSV.height); // mac 全屏之后, 不+1的话, 会导致滑动失效.
        });
    }];
#else
    
#endif
    
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    [self.present startEvent];
    
}

- (void)addPlayboard {
    self.playbar = [MusicPlayBar share];
    
    self.playbar.rootNC = self.navigationController;
    [self.navigationController.view addSubview:self.playbar];
    
    [self.playbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(self.playbar.height);
    }];
    self.playbar.freshBlockRootVC = ^{
        // [self.infoTV reloadRowsAtIndexPaths:self.infoTV.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    };
}



- (UITableView *)addAlertBubbleTV {
    UITableView * oneTV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 130, RootMoreTvCellH * RootMoreArray.count) style:UITableViewStylePlain];
    
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
    
    return oneTV;
}

//- (void)addNcBarSCs {
- (void)addHeadSegmentViews {
    self.titleArray = @[@"歌单", @"文件夹"];
    self.segmentView = ({
        NSArray *titleAry = self.titleArray;
        
        PoporSegmentViewType type = titleAry.count > 4 ? PoporSegmentViewTypeScrollView : PoporSegmentViewTypeViewAuto;
        PoporSegmentView * segmentView = [[PoporSegmentView alloc] initWithStyle:type];
        segmentView.frame = CGRectMake(0, 0, 200, 44);
        segmentView.layer.masksToBounds = YES;
        
        segmentView.titleArray    = titleAry;
        segmentView.originX       = 5;
        segmentView.btContentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        
        // 线条设置
        segmentView.lineWidth     = 18;
        //segmentView.lineWidthFlexible = NO;
        //segmentView.lineWidthScale    = 1.0; // 无效参数
        
        // 颜色
        segmentView.backgroundColor = [UIColor clearColor];
        segmentView.btTitleNColor = PColorBlack;
        segmentView.btTitleSColor = ColorThemeBlue1;
        segmentView.btTitleColorGradualChange = YES;
        
        segmentView.btTitleNFont  = PFONT16;
        segmentView.lineColor     = ColorThemeBlue1;
        
        [segmentView setUI];
        
        [self.view addSubview:segmentView];
        segmentView;
    });
}

- (void)addSVs {
    
    NSLogInt(self.navigationController.navigationBar.translucent);
    
    if (!self.tvArray) {
        self.tvArray = [NSMutableArray new];
    }
    if (!self.tvSV) {
        UIScrollView_pPanGR * sv = [UIScrollView_pPanGR new];
        sv.backgroundColor = [UIColor whiteColor];
        sv.pagingEnabled = YES;
        sv.showsHorizontalScrollIndicator = NO;
        [sv.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
        
        [self.view addSubview:sv];
        
        [sv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo([self statusBarHeight] +self.navigationController.navigationBar.frame.size.height +0);
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(-self.playbar.height);
            make.right.mas_equalTo(0);
        }];
        
        self.tvSV = sv;
    }
    
    {
        //        self.infoTV = ({
        //            UITableView * oneTV = [self addTVs];
        //            oneTV.tag = 0;
        //            oneTV.backgroundColor = PColorTVBG;
        //            [self.tvSV addSubview:oneTV];
        //
        //            //[self setMJFreshSearchCV:oneTV];
        //            [self.tvArray addObject:oneTV];
        //
        //            [oneTV mas_makeConstraints:^(MASConstraintMaker *make) {
        //                make.top.mas_equalTo(0);
        //                make.bottom.mas_equalTo(0);
        //
        //                make.width.mas_equalTo(self.tvSV);
        //                make.height.mas_equalTo(self.tvSV);
        //            }];
        //            oneTV;
        //        });
        self.songListVC = ({
            SongListVC * vc = [[SongListVC alloc] initWithDic:nil];
            
            [self addChildViewController:vc];
            [self.tvSV addSubview:vc.view];
            
            [self.tvArray addObject:vc.view];
            
            [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.bottom.mas_equalTo(0);
                
                make.width.mas_equalTo(self.tvSV);
                make.height.mas_equalTo(self.tvSV);
            }];
            
            vc;
        });
        
        self.localMusicVC = ({
            LocalMusicVC * vc = [[LocalMusicVC alloc] initWithDic:nil];
            
            [self addChildViewController:vc];
            [self.tvSV addSubview:vc.view];
            
            [self.tvArray addObject:vc.view];
            
            [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.bottom.mas_equalTo(0);
                
                make.width.mas_equalTo(self.tvSV);
                make.height.mas_equalTo(self.tvSV);
            }];
            
            vc;
        });
        
        [self.tvSV masSpacingHorizontallyWith:self.tvArray];
    }
    //    for (int i = 0; i<self.titleArray.count; i++) {
    //        UITableView * oneTV = [self addTVs];
    //        oneTV.tag = i;
    //        oneTV.backgroundColor = PColorTVBG;
    //        [self.tvSV addSubview:oneTV];
    //
    //        //[self setMJFreshSearchCV:oneTV];
    //        [self.tvArray addObject:oneTV];
    //
    //        [oneTV mas_makeConstraints:^(MASConstraintMaker *make) {
    //            make.top.mas_equalTo(0);
    //            make.bottom.mas_equalTo(0);
    //
    //            make.width.mas_equalTo(self.tvSV);
    //            make.height.mas_equalTo(self.tvSV);
    //        }];
    //
    //    }
    
    //    [self.tvSV masSpacingHorizontallyWith:self.tvArray];
 
}

- (CGFloat)statusBarHeight {
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        return mainWindow.safeAreaInsets.top;
    }else{
        return 20;
    }
}

@end
