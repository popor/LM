//
//  MusicPlayListTool.m
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.
//

#import "MusicPlayListTool.h"
#import "FileTool.h"

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
        
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        _docPath = [FileTool getAppDocPath]; //获得Document系统文件目录路径
        _yyCache = [YYCache cacheWithName:LmCacheKey];
        
        {
            BOOL isContains = [_yyCache containsObjectForKey:LmPlayListKey];
            if (isContains) {
                id value    = [_yyCache objectForKey:LmPlayListKey];
                _list       = [MusicPlayList yy_modelWithJSON:value];
            }else{
                _list       = [MusicPlayList new];
                _list.array = [NSMutableArray new];
            }
        }
        {
            BOOL isContains = [_yyCache containsObjectForKey:LmConfigKey];
            if (isContains) {
                id value    = [_yyCache objectForKey:LmConfigKey];
                _config     = [MusicConfig yy_modelWithJSON:value];
            }else{
                _config     = [MusicConfig new];
                _config.indexList = -1;
                _config.indexItem = -1;
            }
        }
        
        if (!_list.array) {
            _list.array = [NSMutableArray new];
        }
        _currentTempList = [NSMutableArray new];
    }
    return self;
}


- (void)addListName:(NSString *)name {
    MusicPlayListEntity * list = [MusicPlayListEntity new];
    list.name = name;
    list.viewOrder = -1;
    self.list.array.add(list);
    [self updateList];
}

- (void)updateList {
    [self.yyCache setObject:[self.list yy_modelToJSONString] forKey:LmPlayListKey];
}

- (void)updateConfig {
    [self.yyCache setObject:[self.config yy_modelToJSONString] forKey:LmConfigKey];
}

@end
