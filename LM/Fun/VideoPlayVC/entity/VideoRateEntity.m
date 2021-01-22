//
//  VideoRateEntity.m
//  hywj
//
//  Created by popor on 2020/6/15.
//  Copyright © 2020 popor. All rights reserved.
//

#import "VideoRateEntity.h"

@implementation VideoRateEntity

- (instancetype)initTitle:(NSString *)title value:(CGFloat)value {
    if (self = [super init]) {
        self.title = title;
        self.value = value;
    }
    return self;
}

@end
