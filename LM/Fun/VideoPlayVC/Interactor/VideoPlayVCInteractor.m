//
//  VideoPlayVCInteractor.m
//  hywj
//
//  Created by popor on 2020/12/15.
//  Copyright © 2020 popor. All rights reserved.

#import "VideoPlayVCInteractor.h"

@interface VideoPlayVCInteractor ()

@end

@implementation VideoPlayVCInteractor

- (id)init {
    if (self = [super init]) {
        
        [self initData];
    }
    return self;
}

#pragma mark - VCDataSource
- (void)initData {
    
    self.rateArray = [NSMutableArray new]
    .add(VRE_TV(@"0.5倍速", 	0.5))
    .add(VRE_TV(@"0.75倍速",	0.75))
    .add(VRE_TV(@"1.0倍速",	1.0))
    .add(VRE_TV(@"1.25倍速",	1.25))
    .add(VRE_TV(@"1.5倍速",	1.5))
    .add(VRE_TV(@"2.0倍速",	2.0))
    
    ;
    self.playVideoRate = 1.0;
}

@end
