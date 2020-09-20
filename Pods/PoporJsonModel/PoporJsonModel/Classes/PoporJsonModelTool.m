//
//  PoporJsonModelTool.m
//  JSONModel
//
//  Created by apple on 2019/11/1.
//

#import "PoporJsonModelTool.h"

@implementation PoporJsonModelTool

+ (instancetype)share {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
        
    });
    return instance;
}

@end
