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
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", FT_docPath, ConfigFolderName]
                                  withIntermediateDirectories:YES attributes:nil error:nil];
        //[[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", FT_docPath, ArtworkFolderName]
        //                          withIntermediateDirectories:YES attributes:nil error:nil];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", FT_docPath, DownloadFolderName]
                                  withIntermediateDirectories:YES attributes:nil error:nil];
        
#if TARGET_OS_MACCATALYST
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", FT_docPath, MusicFolderName]
                                  withIntermediateDirectories:YES attributes:nil error:nil];
#else
        
#endif
        
        NSData * configData = [NSData dataWithContentsOfFile:self.configFilePath];
        if (configData) {
            //_config     = [[MusicConfig alloc] initWithString:[[NSString alloc] initWithData:configData encoding:NSUTF8StringEncoding] error:nil];
            _config     = [[MusicConfig alloc] initWithData:configData error:nil];
        } else {
            _config     = [MusicConfig new];
            _config.songIndexList = -1;
            _config.songIndexItem = -1;
        }
        
        _currentTempList = [NSMutableArray<FileEntity> new];
        
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

- (void)updateConfig {
    [self.config.toJSONData writeToFile:self.configFilePath atomically:YES];
    
    //    NSString * file = [self configFilePath];
    //    NSString * json = [self.config toJSONString];
    //    [json writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)configFilePath {
    static NSString * text;
    if (!text) {
        text = [NSString stringWithFormat:@"%@/%@/%@.json", FT_docPath, ConfigFolderName, LmConfigKey];
    }
    return text;
}

// 插图路径
- (NSString *)artworkFolderPath {
    static NSString * text;
    if (!text) {
        text = [NSString stringWithFormat:@"%@/%@", FT_docPath, ArtworkFolderName];
    }
    return text;
}

+ (NSString *)downloadFolderPath {
    static NSString * text;
    if (!text) {
        text = [NSString stringWithFormat:@"%@/%@", FT_docPath, DownloadFolderName];
    }
    return text;
}

@end
