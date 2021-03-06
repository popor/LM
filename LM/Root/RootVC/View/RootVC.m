//
//  RootVC.m
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import "RootVC.h"
#import "RootVCPresenter.h"
#import "RootVCInteractor.h"

#import <PoporRotate/PoporRotate.h>

@interface RootVC ()

@property (nonatomic, strong) RootVCPresenter * present;

@end

@implementation RootVC
@synthesize playbar;
@synthesize titleArray;
@synthesize tvArray;

@synthesize segmentView;
@synthesize tvSV;
@synthesize localMusicVC;
@synthesize netMusicVC;
@synthesize lrcView;

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [NSAssistant setVC:self dic:dic];
    }
    return self;
}

- (void)addMRouterC {
    @weakify(self);
    [MRouterC registerURL:MUrl_freshRootTV toHandel:^(NSDictionary *routerParameters){
        @strongify(self);
        
        [self.localMusicVC.infoTV reloadData];
    }];
    
    [MRouterC registerURL:MUrl_showLrc toHandel:^(NSDictionary *routerParameters){
        @strongify(self);
        if (self.lrcView.isShow) {
            [MGJRouter openURL:MUrl_closeLrc];
        } else {
            self.lrcView.alpha = 1;
            self.lrcView.show = YES;
            [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
                [self.lrcView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(0);
                }];
                
                [self.navigationController.view setNeedsUpdateConstraints];
                
            } completion:^(BOOL finished) {
                [self.lrcView updateInfoTVContentInset];
            }];
        }
    }];
    
    [MRouterC registerURL:MUrl_closeLrc toHandel:^(NSDictionary *routerParameters){
        @strongify(self);
        self.lrcView.show = NO;
        
        [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
            [self.lrcView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.navigationController.view.height -self.playbar.height);
            }];
            
            [self.navigationController.view setNeedsUpdateConstraints];
        } completion:^(BOOL finished) {
            [self.lrcView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
            }];
            self.lrcView.alpha = 0;
        }];
        
    }];
}

- (void)viewDidLoad {
    [self assembleViper];
    [super viewDidLoad];
    PoporPopNormalNC * nc = (PoporPopNormalNC *)self.navigationController;
    nc.navigationBar.translucent = YES;
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
    [self addLrcViews];
    
    // 将歌词加载到playBar下面.
    [self.navigationController.view insertSubview:self.lrcView belowSubview:self.playbar];
   
    @weakify(self);
    {
        self.navigationController.navigationBar.tintColor = App_colorTheme;
    }
    
    {
        [self addHeadSegmentViews];
        
        // 组合, 否则显示和pop回来之后的效果不一样
        self.navigationItem.titleView = self.segmentView;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.navigationItem.titleView = nil;
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.navigationItem.titleView = self.segmentView;
        });
        
        [self addSVs];
        
        self.segmentView.weakLinkSV = self.tvSV;
        self.segmentView.weakLinkSV.delegate = self.segmentView;
    }
    BOOL needMonitorFrame = NO;
#if TARGET_OS_MACCATALYST
    needMonitorFrame = YES;
#else
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        needMonitorFrame = YES;
    }
#endif
    
    if (needMonitorFrame) {
        // 模式下需要监听用户缩放frame
        [RACObserve(self.navigationController.view, frame) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            // NSLog(@"刷新frame");
            if (fabs(self.playbar.timeDurationL.right -self.view.width) > 5) {
                [self reloadTv_PlayBarFrame_sync];
            } else {
                [self reloadTv_PlayBarFrame_sync];
            }
            [self.lrcView updateInfoTVContentInset];
        }];
    }
    
    [self addMRouterC];
    
    [[self.navigationController rac_signalForSelector:@selector(viewWillLayoutSubviews)] subscribeNext:^(RACTuple * _Nullable x) {
        @strongify(self);
        
        [self reloadPlayBarFrame];
    }];
    
    // 延迟设置系统启动
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        PoporRotate * pr = [PoporRotate share];
        pr.appLoaded = YES;
    });
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self reloadTvFrame];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.segmentView.currentPage != 0) { // 主要用于 ios 旋转屏幕
            CGRect rect = CGRectMake(self.tvSV.width *self.segmentView.currentPage, 0, self.tvSV.width, 1);
            [self.tvSV scrollRectToVisible:rect animated:YES];
        }
    });
}

- (void)reloadTvFrame {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tvSV.contentSize = CGSizeMake(ceil(self.tvSV.width +1)*self.titleArray.count, self.tvSV.height); // mac 全屏之后, 不+1的话, 会导致滑动失效.
    });
}

- (void)reloadPlayBarFrame {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.playbar updateProgressSectionFrame];
    });
}

// 这个主要用于mac同步执行
- (void)reloadTv_PlayBarFrame_sync {
    self.tvSV.contentSize = CGSizeMake(ceil(self.tvSV.width +1)*self.titleArray.count, self.tvSV.height); // mac 全屏之后, 不+1的话, 会导致滑动失效.
    [self.playbar updateProgressSectionFrame];
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
}

- (void)addLrcViews {
    self.lrcView = [[LrcView alloc] initWithDic:nil];
    [self.navigationController.view addSubview:self.lrcView];
    [self.lrcView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        
        //make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-self.playbar.height);
    }];
}

- (void)addHeadSegmentViews {
    //self.titleArray = @[@"歌单", @"本地", @"网络"];
    self.titleArray = @[@"本地", @"网络"];
    self.segmentView = ({
        NSArray *titleAry = self.titleArray;
        
        PoporSegmentViewType type = titleAry.count > 4 ? PoporSegmentViewTypeScrollView : PoporSegmentViewTypeViewAuto;
        type = PoporSegmentViewTypeView;
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
        
        segmentView.btTitleNColor = App_colorTextN1;
        segmentView.btTitleSColor = App_colorTextS1;
        segmentView.btTitleColorGradualChange = YES;
        
        segmentView.btTitleNFont  = [UIFont boldSystemFontOfSize:16];
        segmentView.lineColor     = UIColor.clearColor;
        
        [segmentView setUI];
        
        segmentView;
    });
}

- (void)addSVs {
    
    if (!self.tvArray) {
        self.tvArray = [NSMutableArray new];
    }
    if (!self.tvSV) {
        UIScrollView_pPanGR * sv = [UIScrollView_pPanGR new];
        sv.backgroundColor = App_colorBg1;
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
        self.netMusicVC = ({
            NetMusicVC * vc = [[NetMusicVC alloc] initWithDic:nil];
            
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
 
}

- (CGFloat)statusBarHeight {
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        return mainWindow.safeAreaInsets.top;
    }else{
        return 20;
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13, *)) {
        if ([ThemeColor share].previousUserInterfaceStyle != previousTraitCollection.userInterfaceStyle) {
            [ThemeColor share].previousUserInterfaceStyle = previousTraitCollection.userInterfaceStyle;
            NSLog(@"修改系统颜色!");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                for (UIButton * bt in self.segmentView.btArray) {
                    if (bt.tag != self.segmentView.currentPage) {
                        [bt setTitleColor:self.segmentView.btTitleNColor forState:UIControlStateNormal];
                    }
                }
            });
            
        }
    }
    
    //self.view.tag = self.view.tag +1;
    //NSLogInteger(self.view.tag);
}


@end
