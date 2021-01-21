//
//  VideoPlayVC.m
//  hywj
//
//  Created by popor on 2020/12/15.
//  Copyright © 2020 popor. All rights reserved.

#import "VideoPlayVC.h"
#import "VideoPlayVCPresenter.h"
#import "VideoPlayVCInteractor.h"


//#import "UIViewController+pRootVC.h"
#import "PoporAvPlayerRecord.h"
#import "PoporAvPlayerBundle.h"

#import "UIDevice+pOrientation.h"
#import "UIViewController+pAutorotate.h"
#import "PAutorotate.h"

#define DeviceStatusBarHeight [UIDevice statusBarHeight]
#define VideoScale            0.5625 // (9.0 / 16.0)

@interface VideoPlayVC ()

@property (nonatomic, strong) VideoPlayVCPresenter * present;

@property (nonatomic, strong) UIButton * popBT;

@property (nonatomic, copy  ) NSArray * segmentTitleArray;

@property (nonatomic        ) BOOL wwanPause;
@property (nonatomic        ) BOOL needHiddenStatus;

@end

@implementation VideoPlayVC

@synthesize videoPlayView;
@synthesize record;
@synthesize videoConfigTvView;

@synthesize devicePortraint;

@synthesize avDownloadBT;
@synthesize avFavBT;
@synthesize avShareBT;
@synthesize coverFavBT;
@synthesize coverShareBT;
@synthesize shareIV;

@synthesize videoInfoArray;

+ (void)load {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        [MRouterC registerURL:MUrl_videoPlayOnly toHandel:^(NSDictionary *routerParameters){
            NSMutableDictionary * dic = [MRouterC mixDic:routerParameters];
            UIViewController * vc = [[[self class] alloc] initWithDic:dic];
            [MRouterC pushVC:vc dic:dic];
        }];
    });
}

- (void)dealloc {
    [PoporAvPlayerRecord share].hiddenControlBarBlock = nil;
    
    [MGJRouter openURL:MUrl_playBarOpen];
    
    if (self.videoPlayView) {
        [self.videoPlayView pausePlay];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.videoPlayView) {
        [self.videoPlayView pausePlay];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [PAutorotate share].autorotate = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    @weakify(self);
    [PoporAvPlayerRecord share].hiddenControlBarBlock = ^(BOOL hidden) {
        @strongify(self);
        self.needHiddenStatus = hidden;
        [self setNeedsStatusBarAppearanceUpdate];
    };
}


- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [NSAssistant setVC:self dic:dic];
        self.hiddenNcBar = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [self assembleViper];
    [super viewDidLoad];
    
    self.title = @"";
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
        VideoPlayVCPresenter * present = [VideoPlayVCPresenter new];
        VideoPlayVCInteractor * interactor = [VideoPlayVCInteractor new];
        
        self.present = present;
        [present setMyInteractor:interactor];
        [present setMyView:self];
        
        [self addViews];
        [self startEvent];
    }
}

- (void)addViews {
    self.record = [PoporAvPlayerRecord share];
    [self.record setDefaultData];
    
    [self addStatusBlackView];
    [self addVideoPlayViews];
    
    [self monitorNetStatus];
    
    [self.view bringSubviewToFront:self.videoPlayView];
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    [self.present startEvent];
    
}

// -----------------------------------------------------------------------------
- (void)addStatusBlackView {
    self.view.backgroundColor = UIColor.whiteColor;
}

- (void)addVideoPlayViews {
    
    self.videoPlayView = ({
        PoporAvPlayerView * view = [PoporAvPlayerView new];
        //view.backgroundColor = [UIColor redColor];
        view.delegate = self.present;
        view.frame = CGRectMake(0, DeviceStatusBarHeight, PScreenWidth, PScreenWidth * VideoScale);
        
        [self.view addSubview:view];
        
        view;
    });
    
    [self.videoPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(-0);
        make.right.mas_equalTo(-0);
    }];
    
    
    
    // 因为蒙层的收藏按钮高度和播放器的算法不一样, 所以先隐藏, 随后再打开
    //self.videoPlayView.topBar.alpha = 0;
    
    [self.videoPlayView addDefaultBlurImage];
    
    [self.videoPlayView videoPanGrFailGr:self.navigationController.interactivePopGestureRecognizer];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        PoporAvPlayerBottomBar * bb = self.videoPlayView.bottomBar;
        [bb.definitionBT mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(bb.rateBT);
            make.right.mas_equalTo(bb.rateBT.mas_left).mas_offset(-5);
            make.size.mas_equalTo(CGSizeMake(40, 30));
        }];
        
        //PoporAvPlayerTopBar * tb = self.videoPlayView.topBar;
        //tb.backgroundColor = UIColor.yellowColor;
    });
}

// MARK: 监测屏幕旋转方向
- (void) viewDidLayoutSubviews {
    [self.view bringSubviewToFront:self.popBT];
    //NSLog(@"%s", __func__);
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown: { // 竖屏
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            [self videoPortraint];
            break;
        }
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: { // 横屏
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            [self videoLandscape];
            break;
        }
        case UIInterfaceOrientationUnknown:
            break;
        default:
            break;
    }
    
}

- (void)videoPortraint {
    self.devicePortraint = YES;
    self.videoPlayView.bottomBar.landscapeButton.selected = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    
    //self.videoPlayView.frame = CGRectMake(0, DeviceStatusBarHeight, PScreenWidth, PScreenWidth * VideoScale);
    [self.videoPlayView.topBar mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat top = [UIDevice statusBarHeight];
        if (top == 0) {
            make.top.mas_equalTo(0);
        } else {
            make.top.mas_equalTo(top);
        }
        
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    [self.videoPlayView.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-[UIDevice safeAreaInsets].bottom-10);
    }];
    
    
    self.videoPlayView.bottomBar.videoNumBT.hidden   = YES;
    self.videoPlayView.bottomBar.definitionBT.hidden = NO;
    self.videoPlayView.topBar.rightBT.hidden         = YES;
    
    self.avShareBT.hidden = NO;
    self.avFavBT.hidden   = NO;

    
    if (@available(iOS 11, *)) {
        [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    }
}

- (void)videoLandscape {
    self.devicePortraint = NO;
    self.videoPlayView.bottomBar.landscapeButton.selected = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    
    //self.videoPlayView.frame = CGRectMake(0, 0, PScreenHeight, PScreenWidth);
    [self.videoPlayView.topBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo([UIDevice safeAreaInsets].left);
        make.right.mas_equalTo(-[UIDevice safeAreaInsets].right);
    }];
    [self.videoPlayView.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo([UIDevice safeAreaInsets].left);
        make.right.mas_equalTo(-[UIDevice safeAreaInsets].right);
        
        make.bottom.mas_equalTo(-10);
    }];
    
    
    self.videoPlayView.bottomBar.videoNumBT.hidden   = YES;
    self.videoPlayView.bottomBar.definitionBT.hidden = NO;
    self.videoPlayView.topBar.rightBT.hidden         = YES;
    
    self.avShareBT.hidden = YES;
    self.avFavBT.hidden   = YES;
    
    if (@available(iOS 11, *)) {
        [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    }
}

- (void)updateBarMasonry {
}

- (void)videoPortraintOrientation {
    [self setInterfaceOrientation:UIDeviceOrientationPortrait];
}

- (void)videoLandscapeOrientation {
    [self setInterfaceOrientation:UIDeviceOrientationLandscapeLeft];
}

- (void)setInterfaceOrientation:(UIDeviceOrientation)orientation {
    [UIDevice updateOrientation:orientation];
}

- (VideoConfigTvView *)videoConfigTvView {
    if (!videoConfigTvView) {
        videoConfigTvView = [VideoConfigTvView new];
        videoConfigTvView.delegate = self.present;
        
    }
    //NSLog(@"%p", videoConfigTvView);
    return videoConfigTvView;
}

- (void)popBackAction {
    if (self.isDevicePortraint) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self videoPortraintOrientation];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - VC override
- (BOOL)prefersStatusBarHidden {
    // 现在全部交给 视频控制器
    return self.needHiddenStatus;
    
    //    之前的, 竖屏全显示, 横屏交给视频控制器
    //    if (self.devicePortraint) {
    //        return NO;
    //    } else {
    //        return self.needHiddenStatus;
    //    }
}

//是否可以旋转
//- (BOOL)shouldAutorotate {
//    return YES;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskLandscapeLeft;
//}

////由模态推出的视图控制器 优先支持的屏幕方向
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//    return UIInterfaceOrientationPortrait;
//}

// MARK: Status Bar颜色随底色高亮变化
- (UIStatusBarStyle)preferredStatusBarStyle {
    //return UIStatusBarStyleDefault;
    return UIStatusBarStyleLightContent;
}

// 隐藏白条
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

// 监测网络
- (void)monitorNetStatus {
    //    目前只考虑本地播放
    //    @weakify(self);
    //    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:NetStatusNC_Wifi object:nil] subscribeNext:^(NSNotification * _Nullable x) {
    //        @strongify(self);
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //            [self resumePalyWifi];
    //        });
    //    }];
    //
    //    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:NetStatusNC_4G object:nil] subscribeNext:^(NSNotification * _Nullable x) {
    //        @strongify(self);
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //            [self ausePaly4g];
    //        });
    //    }];
}

- (void)ausePaly4g {
    self.wwanPause = YES;
    
    [self.videoPlayView showControlBar];
    
    [self.videoPlayView pausePlay];
    
    if (@available(iOS 10, *)) {
        self.videoPlayView.playerItem.preferredForwardBufferDuration = 20;
    } else {
        [self.videoPlayView.playerItem cancelPendingSeeks];
        [self.videoPlayView.playerItem.asset cancelLoading];
    }
}

- (void)resumePalyWifi {
    if (self.wwanPause) {
        self.wwanPause = NO;
        
        [self.videoPlayView showControlBar];
        [self.videoPlayView startPlay];
        
        if (@available(iOS 10, *)) {
            self.videoPlayView.playerItem.preferredForwardBufferDuration = 600;
        } else {
            [self.videoPlayView.playerItem cancelPendingSeeks];
            [self.videoPlayView.playerItem.asset cancelLoading];
        }
    }
}
@end
