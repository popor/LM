//
//  RootVC.m
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import "RootVC.h"
#import "RootVCPresenter.h"
#import "RootVCRouter.h"

#import "ListVCRouter.h"
#import "MineVCRouter.h"
#import "UINavigationController+Jch.h"

@interface RootVC ()

@property (nonatomic, strong) RootVCPresenter * present;

@end

@implementation RootVC

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [NSAssistant setVC:self dic:dic];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.title) {
        self.title = @"";
    }
    self.view.backgroundColor = [UIColor whiteColor];
    if (!self.present) {
        [RootVCRouter setVCPresent:self];
    }
    
    [self addViews];
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
    [self addVCs];
    
}

- (void)addVCs {
    PoporPopNormalNC * listNC = [[PoporPopNormalNC alloc]initWithRootViewController:[ListVCRouter vcWithDic:nil]];
    PoporPopNormalNC * mineNC = [[PoporPopNormalNC alloc]initWithRootViewController:[MineVCRouter vcWithDic:nil]];
    
    NSArray * ncArray = @[listNC, mineNC];
    NSArray * titleArray = @[@"列表",@"我的"];
    NSArray * imageArrayN = @[[UIImage imageFromColor:[UIColor grayColor] size:CGSizeMake(1, 1)],
                              [UIImage imageFromColor:[UIColor grayColor] size:CGSizeMake(1, 1)]];
    NSArray * imageArrayS = @[[UIImage imageFromColor:[UIColor darkGrayColor] size:CGSizeMake(1, 1)],
                              [UIImage imageFromColor:[UIColor darkGrayColor] size:CGSizeMake(1, 1)]];
    
    for (PoporPopNormalNC * nc in ncArray) {
        nc.updateBarBackTitle = YES;
        nc.barBackTitle = @"";
        nc.barBackImage = [UIImage imageNamed:@"NCBack"];
        nc.autoHidesBottomBarWhenPushed = YES;
        
        [nc setVRSNCBarTitleColor];
        [nc setInteractivePopGRDelegate];
    }
    [self setViewControllers:ncArray];
    for (int i = 0; i < self.tabBar.items.count; i++) {
        UITabBarItem * item;
        item = [[UITabBarItem alloc] initWithTitle:titleArray[i] image:[UIImage imageNamed:imageArrayN[i]] tag:i];
        item.selectedImage = [imageArrayS[i] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        //item.titlePositionAdjustment = UIOffsetMake(0, 100);
        self.viewControllers[i].tabBarItem = item;
    }
    self.tabBar.tintColor = ColorBlue1;
    //weakSelf.tabBar.barTintColor = ColorBlue1;
    //weakSelf.tabBar.tintColor = [UIColor yellowColor];
    
    [self setSelectedIndex:0];
}

@end
