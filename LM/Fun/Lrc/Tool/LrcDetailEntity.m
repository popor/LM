//
//  LrcDetailEntity.m
//  LM
//
//  Created by popor on 2020/10/14.
//  Copyright © 2020 popor. All rights reserved.
//

#import "LrcDetailEntity.h"

@implementation LrcDetailEntity

+ (NSInteger)timeFromText:(NSString *)timeText {
    NSRange range = [timeText rangeOfString:@":"];
    NSInteger mm  = [timeText substringToIndex:range.location].integerValue;
    NSInteger ss  = [timeText substringFromIndex:range.location +1].integerValue;
    NSInteger time = mm*60 +ss;
    return time;
}
@end
