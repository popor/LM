//
//  AppSetVC.m
//  LM
//
//  Created by popor on 2021/1/14.
//  Copyright © 2021 popor. All rights reserved.

#import "AppSetVC.h"
#import "AppSetVCPresenter.h"
#import "AppSetVCInteractor.h"

@interface AppSetVC ()

@property (nonatomic, strong) AppSetVCPresenter * present;

@end

@implementation AppSetVC
@synthesize infoTV;
@synthesize versionL;

+ (void)load {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        [MRouterC registerURL:MUrl_appSet toHandel:^(NSDictionary *routerParameters){
            NSMutableDictionary * dic = [MRouterC mixDic:routerParameters];
            UIViewController * vc = [[[self class] alloc] initWithDic:dic];
            [MRouterC pushVC:vc dic:dic];
        }];
    });
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [self assembleViper];
    [super viewDidLoad];
    
    if (!self.title) {
        self.title = @"设置";
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
        AppSetVCPresenter * present = [AppSetVCPresenter new];
        AppSetVCInteractor * interactor = [AppSetVCInteractor new];
        
        self.present = present;
        [present setMyInteractor:interactor];
        [present setMyView:self];
        
        [self addViews];
        [self startEvent];
    }
}

- (void)addViews {
    self.infoTV = [self addTVs];
    
    self.versionL = ({
        UILabel * oneL = [UILabel new];
        oneL.frame               = CGRectMake(0, -40, self.view.width, 30);
        oneL.backgroundColor     = [UIColor clearColor]; // ios8 之前
        oneL.font                = [UIFont systemFontOfSize:15];
        oneL.textColor           = App_colorTextN2;
        oneL.layer.masksToBounds = YES; // ios8 之后 lableLayer 问题
        oneL.numberOfLines       = 1;
        oneL.textAlignment       = NSTextAlignmentCenter;
        
        oneL.text = [NSString stringWithFormat:@"%@ (%@)", [UIDevice getAppVersion_short], [UIDevice getAppVersion_build]];
        oneL;
    });
    
    [self.infoTV addSubview:self.versionL];
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    [self.present startEvent];
    
}

// -----------------------------------------------------------------------------
- (UITableView *)addTVs {
    UITableView * oneTV = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    //oneTV.separatorColor  = PColorBlackE;
    oneTV.backgroundColor = UIColor.whiteColor;
    oneTV.delegate   = self.present;
    oneTV.dataSource = self.present;
    
    oneTV.allowsMultipleSelectionDuringEditing = YES;
    oneTV.directionalLockEnabled = YES;
    
    oneTV.estimatedRowHeight           = 0;
    oneTV.estimatedSectionHeaderHeight = 0;
    oneTV.estimatedSectionFooterHeight = 0;
    
    [self.view addSubview:oneTV];
    
    [oneTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    return oneTV;
}


@end
