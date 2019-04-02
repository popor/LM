//
//  SongListDetailVCRouter.m
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.

#import "SongListDetailVCRouter.h"
#import "SongListDetailVCPresenter.h"
#import "SongListDetailVC.h"

@implementation SongListDetailVCRouter

+ (UIViewController *)vcWithDic:(NSDictionary *)dic {
    SongListDetailVC * vc = [[SongListDetailVC alloc] initWithDic:dic];
    SongListDetailVCPresenter * present = [SongListDetailVCPresenter new];
    
    [vc setMyPresent:present];
    [present setMyView:vc];
    
    return vc;
}

+ (void)setVCPresent:(UIViewController *)vc {
    if ([vc isKindOfClass:[SongListDetailVC class]]) {
        SongListDetailVC * oneVC = (SongListDetailVC *)vc;
        SongListDetailVCPresenter * present = [SongListDetailVCPresenter new];
        
        [oneVC setMyPresent:present];
        [present setMyView:oneVC];
    }
}

@end
