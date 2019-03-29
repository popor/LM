//
//  WifiAddFileVCRouter.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import "WifiAddFileVCRouter.h"
#import "WifiAddFileVCPresenter.h"
#import "WifiAddFileVC.h"

@implementation WifiAddFileVCRouter

+ (UIViewController *)vcWithDic:(NSDictionary *)dic {
    WifiAddFileVC * vc = [[WifiAddFileVC alloc] initWithDic:dic];
    WifiAddFileVCPresenter * present = [WifiAddFileVCPresenter new];
    
    [vc setMyPresent:present];
    [present setMyView:vc];
    
    return vc;
}

+ (void)setVCPresent:(UIViewController *)vc {
    if ([vc isKindOfClass:[WifiAddFileVC class]]) {
        WifiAddFileVC * oneVC = (WifiAddFileVC *)vc;
        WifiAddFileVCPresenter * present = [WifiAddFileVCPresenter new];
        
        [oneVC setMyPresent:present];
        [present setMyView:oneVC];
    }
}

@end
