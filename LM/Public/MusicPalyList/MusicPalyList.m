//
//  MusicPalyList.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import "MusicPalyList.h"

@implementation MusicPalyList

+ (MusicPalyList *)share {
    static dispatch_once_t once;
    static MusicPalyList * instance;
    dispatch_once(&once, ^{
        instance = [self new];
        
    });
    return instance;
}

@end
