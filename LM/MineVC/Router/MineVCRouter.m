//
//  MineVCRouter.m
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import "MineVCRouter.h"
#import "MineVCPresenter.h"
#import "MineVC.h"

@implementation MineVCRouter

+ (UIViewController *)vcWithDic:(NSDictionary *)dic {
    MineVC * vc = [[MineVC alloc] initWithDic:dic];
    MineVCPresenter * present = [MineVCPresenter new];
    
    [vc setMyPresent:present];
    [present setMyView:vc];
    
    return vc;
}

+ (void)setVCPresent:(UIViewController *)vc {
    if ([vc isKindOfClass:[MineVC class]]) {
        MineVC * oneVC = (MineVC *)vc;
        MineVCPresenter * present = [MineVCPresenter new];
        
        [oneVC setMyPresent:present];
        [present setMyView:oneVC];
    }
}

@end
