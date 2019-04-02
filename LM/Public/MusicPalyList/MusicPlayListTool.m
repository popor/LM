//
//  MusicPlayListTool.m
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.
//

#import "MusicPlayListTool.h"

#import <YYCache/YYCache.h>
#import <YYModel/YYModel.h>

@interface MusicPlayListTool ()

@property (nonatomic, strong) YYCache *yyCache;

@end

@implementation MusicPlayListTool

+ (MusicPlayListTool *)share {
    static dispatch_once_t once;
    static MusicPlayListTool * instance;
    dispatch_once(&once, ^{
        instance = [self new];
        instance.yyCache   = [YYCache cacheWithName:LmCacheKey];
        BOOL isContains = [instance.yyCache containsObjectForKey:LmPlayListKey];
        if (isContains) {
            id value = [instance.yyCache objectForKey:LmPlayListKey];
            instance.list = [MusicPlayList yy_modelWithJSON:value];
        }else{
            instance.list = [MusicPlayList new];
            instance.list.array = [NSMutableArray new];
        }
        if (!instance.list.array) {
            instance.list.array = [NSMutableArray new];
        }
    });
    return instance;
}

- (void)addListName:(NSString *)name {
    MusicPlayListEntity * list = [MusicPlayListEntity new];
    list.name = name;
    
    self.list.array.add(list);
    [self update];
}

- (void)update {
    [self.yyCache setObject:[self.list yy_modelToJSONString] forKey:LmPlayListKey];
}

@end
