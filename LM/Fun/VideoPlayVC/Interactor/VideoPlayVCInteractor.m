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
    
    self.rateArray = [NSMutableArray new];
    {
        VideoRateEntity * entity = [VideoRateEntity new];
        entity.title = @"0.5倍速";
        entity.value = 0.5;
        
        [self.rateArray addObject:entity];
    }
    {
        VideoRateEntity * entity = [VideoRateEntity new];
        entity.title = @"0.75倍速";
        entity.value = 0.75;
        
        [self.rateArray addObject:entity];
    }
    {
        VideoRateEntity * entity = [VideoRateEntity new];
        entity.title = @"1.0倍速";
        entity.value = 1.0;
        
        [self.rateArray addObject:entity];
    }
    {
        VideoRateEntity * entity = [VideoRateEntity new];
        entity.title = @"1.25倍速";
        entity.value = 1.25;
        
        [self.rateArray addObject:entity];
    }
    {
        VideoRateEntity * entity = [VideoRateEntity new];
        entity.title = @"1.5倍速";
        entity.value = 1.5;
        
        [self.rateArray addObject:entity];
    }
    {
        VideoRateEntity * entity = [VideoRateEntity new];
        entity.title = @"2.0倍速";
        entity.value = 2.0;
        
        [self.rateArray addObject:entity];
    }
    
    self.playVideoRate = 1.0;
}

@end
