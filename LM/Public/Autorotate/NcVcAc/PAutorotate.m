//
//  PAutorotate.m
//  hywj
//
//  Created by popor on 2020/7/25.
//  Copyright © 2020 popor. All rights reserved.
//

#import "PAutorotate.h"

@implementation PAutorotate

+ (instancetype)share {
    static dispatch_once_t once;
    static PAutorotate * instance;
    dispatch_once(&once, ^{
        instance = [PAutorotate new];
        //instance.autorotate        = YES;
        //instance.autorotate_moment = YES;
    });
    return instance;
}

- (void)setAutorotate_moment:(BOOL)autorotate_moment {
    if (autorotate_moment) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.autorotate_moment = NO;
        });
    }
    _autorotate_moment = autorotate_moment;
}

@end
