//
//  RootVCRouter.m
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import "RootVCRouter.h"
#import "RootVCPresenter.h"
#import "RootVC.h"

@implementation RootVCRouter

+ (UIViewController *)vcWithDic:(NSDictionary *)dic {
    RootVC * vc = [[RootVC alloc] initWithDic:dic];
    RootVCPresenter * present = [RootVCPresenter new];
    
    [vc setMyPresent:present];
    [present setMyView:vc];
    
    return vc;
}

+ (void)setVCPresent:(UIViewController *)vc {
    if ([vc isKindOfClass:[RootVC class]]) {
        RootVC * oneVC = (RootVC *)vc;
        RootVCPresenter * present = [RootVCPresenter new];
        
        [oneVC setMyPresent:present];
        [present setMyView:oneVC];
    }
}

@end
