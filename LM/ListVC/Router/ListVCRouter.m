//
//  ListVCRouter.m
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import "ListVCRouter.h"
#import "ListVCPresenter.h"
#import "ListVC.h"

@implementation ListVCRouter

+ (UIViewController *)vcWithDic:(NSDictionary *)dic {
    ListVC * vc = [[ListVC alloc] initWithDic:dic];
    ListVCPresenter * present = [ListVCPresenter new];
    
    [vc setMyPresent:present];
    [present setMyView:vc];
    
    return vc;
}

+ (void)setVCPresent:(UIViewController *)vc {
    if ([vc isKindOfClass:[ListVC class]]) {
        ListVC * oneVC = (ListVC *)vc;
        ListVCPresenter * present = [ListVCPresenter new];
        
        [oneVC setMyPresent:present];
        [present setMyView:oneVC];
    }
}

@end
