//
//  MusicPlayListTool.m
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.
//

#import "MusicPlayListTool.h"
#import "FileTool.h"

@interface MusicPlayListTool ()

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
        
        NSData * listData = [NSData dataWithContentsOfFile:self.listFilePath];
        NSData * configData = [NSData dataWithContentsOfFile:self.configFilePath];
        
        if (listData) {
            _list       = [[MusicPlayList alloc] initWithData:listData error:nil];
        } else {
            _list       = [MusicPlayList new];
            _list.songListArray = [NSMutableArray new];
        }
        
        if (configData) {
            _config     = [[MusicConfig alloc] initWithData:configData error:nil];
        } else {
            _config     = [MusicConfig new];
            _config.indexList = -1;
            _config.indexItem = -1;
        }
        
        if (!_list.songListArray) {
            _list.songListArray = [NSMutableArray new];
        }
        _currentTempList = [NSMutableArray new];
    }
    return self;
}


- (void)addListName:(NSString *)name {
    MusicPlayListEntity * list = [MusicPlayListEntity new];
    list.name = name;
    list.viewOrder = -1;
    self.list.songListArray.add(list);
    [self updateList];
}

- (void)updateList {
    [[self.list toJSONString] writeToFile:self.listFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)updateConfig {
    [[self.config toJSONString] writeToFile:self.configFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


- (NSString *)listFilePath {
    return [NSString stringWithFormat:@"%@/%@", [FileTool getAppDocPath], LmPlayListKey];
}

- (NSString *)configFilePath {
    return [NSString stringWithFormat:@"%@/%@", [FileTool getAppDocPath], LmConfigKey];
}

@end
