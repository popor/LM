//
//  MusicConfig.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import "MusicConfig.h"

@implementation MusicConfig

+ (MusicConfig *)share {
    static dispatch_once_t once;
    static MusicConfig * instance;
    dispatch_once(&once, ^{
        instance = [self new];
        
    });
    return instance;
}

@end
