//
//  LrcKugouListEntity.m
//  LM
//
//  Created by popor on 2020/10/15.
//  Copyright © 2020 popor. All rights reserved.
//

#import "LrcKugouListEntity.h"

@implementation LrcKugouListUnitEntity

@end

@implementation LrcKugouListEntity

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"lrcArray": @"candidates",
    }];
}

@end
