//
//  LocalMusicVCRouter.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import "LocalMusicVCRouter.h"
#import "LocalMusicVCPresenter.h"
#import "LocalMusicVC.h"

@implementation LocalMusicVCRouter

+ (UIViewController *)vcWithDic:(NSDictionary *)dic {
    LocalMusicVC * vc = [[LocalMusicVC alloc] initWithDic:dic];
    LocalMusicVCPresenter * present = [LocalMusicVCPresenter new];
    
    [vc setMyPresent:present];
    [present setMyView:vc];
    
    return vc;
}

+ (void)setVCPresent:(UIViewController *)vc {
    if ([vc isKindOfClass:[LocalMusicVC class]]) {
        LocalMusicVC * oneVC = (LocalMusicVC *)vc;
        LocalMusicVCPresenter * present = [LocalMusicVCPresenter new];
        
        [oneVC setMyPresent:present];
        [present setMyView:oneVC];
    }
}

@end
