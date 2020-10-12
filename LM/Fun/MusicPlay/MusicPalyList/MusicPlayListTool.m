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
        
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", FT_docPath, RecordFolderName]
                                  withIntermediateDirectories:YES attributes:nil error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", FT_docPath, MusicFolderName]
                                  withIntermediateDirectories:YES attributes:nil error:nil];
        
        
        NSData * listData   = [NSData dataWithContentsOfFile:self.listFilePath];
        NSData * configData = [NSData dataWithContentsOfFile:self.configFilePath];
        
        if (listData) {
            //_list = [[MusicPlayList alloc] initWithString:[[NSString alloc] initWithData:listData encoding:NSUTF8StringEncoding] error:nil];
            _list = [[MusicPlayList alloc] initWithData:listData error:nil];
        } else {
            _list       = [MusicPlayList new];
        }
        
        if (configData) {
            //_config     = [[MusicConfig alloc] initWithString:[[NSString alloc] initWithData:configData encoding:NSUTF8StringEncoding] error:nil];
            _config     = [[MusicConfig alloc] initWithData:configData error:nil];
        } else {
            _config     = [MusicConfig new];
            _config.songIndexList = -1;
            _config.songIndexItem = -1;
        }
        if (!_list) {
            _list = [MusicPlayList new];
        }
        _currentTempList = [NSMutableArray new];
        
        [self addMgjrouter];
    }
    return self;
}


- (void)addMgjrouter {
    @weakify(self);
    [MRouterC registerURL:MUrl_savePlayConfig toHandel:^(NSDictionary *routerParameters){
        @strongify(self);
        
        [self updateConfig];
    }];
}

- (void)addListName:(NSString *)name {
    MusicPlayListEntity * list = [MusicPlayListEntity new];
    list.name = name;
    list.viewOrder = -1;
    self.list.songListArray.add(list);
    [self updateSongList];
}

- (void)updateSongList {
    [self.list.toJSONData writeToFile:self.listFilePath atomically:YES];

    //    NSString * path = [self listFilePath];
    //    NSString * json = [self.list toJSONString];
    //    [json writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)updateConfig {
    [self.config.toJSONData writeToFile:self.configFilePath atomically:YES];
    
    //    NSString * file = [self configFilePath];
    //    NSString * json = [self.config toJSONString];
    //    [json writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


- (NSString *)listFilePath {
    return [NSString stringWithFormat:@"%@/%@/%@.json", FT_docPath, RecordFolderName, LmPlayListKey];
}

- (NSString *)configFilePath {
    return [NSString stringWithFormat:@"%@/%@/%@.json", FT_docPath, RecordFolderName, LmConfigKey];
}

@end
