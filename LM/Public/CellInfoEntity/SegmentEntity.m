//
//  SegmentEntity.m
//  Ycysj
//
//  Created by 王凯庆 on 2020/2/10.
//  Copyright © 2020 popor. All rights reserved.
//

#import "SegmentEntity.h"

@implementation SegmentEntity

- (id)initTag:(int)tag title:(NSString *)title nColor:(UIColor *)nColor sColor:(UIColor *)sColor {
    if (self = [super init]) {
        _tag = tag;
        _title = title;
        _titleNColor = nColor;
        _titleSColor = sColor;
    }
    return self;
}

- (id)initTag:(int)tag title:(NSString *)title nColor:(UIColor *)nColor bgColor:(UIColor *)bgColor {
    if (self = [super init]) {
        _tag = tag;
        _title = title;
        _titleNColor = nColor;
        _bgColor = bgColor;
    }
    return self;
}

- (id)initTag:(int)tag title:(NSString *)title nColor:(UIColor *)nColor sColor:(UIColor *)sColor bgColor:(UIColor *)bgColor {
    if (self = [super init]) {
        _tag = tag;
        _title = title;
        _titleNColor = nColor;
        _titleSColor = sColor;
        _bgColor = bgColor;
    }
    return self;
}
@end


@implementation SegmentEntityTool

+ (instancetype)share {
    static dispatch_once_t once;
    static SegmentEntityTool * instance;
    dispatch_once(&once, ^{
        instance = [self new];
        instance.arrayDic      = [NSMutableDictionary new];
        instance.entityDicDic  = [NSMutableDictionary new];
        instance.titleArrayDic = [NSMutableDictionary new];
    });
    return instance;
}

+ (void)setArray:(NSArray *)array class:(Class)class {
    SegmentEntityTool * tool = [SegmentEntityTool share];
    
    [tool.arrayDic setObject:array forKey:NSStringFromClass(class)];
    NSMutableDictionary * dicDic = [NSMutableDictionary new];
    NSMutableArray * titleArray  = [NSMutableArray new];
    for (int i=0;i<array.count;i++) {
        SegmentEntity * e = array[i];
        [dicDic setObject:e forKey:@(e.tag)];
        [titleArray addObject:e.title];
    }
    [tool.entityDicDic setObject:dicDic forKey:NSStringFromClass(class)];
    [tool.titleArrayDic setObject:titleArray forKey:NSStringFromClass(class)];
    
}

+ (NSMutableArray *)titleArrayClass:(Class)class {
    SegmentEntityTool * tool = [SegmentEntityTool share];
    
    return tool.titleArrayDic[NSStringFromClass(class)];
}

+ (NSMutableDictionary *)entityDicClass:(Class)class {
    SegmentEntityTool * tool = [SegmentEntityTool share];
    
    return tool.entityDicDic[NSStringFromClass(class)];
}

@end
