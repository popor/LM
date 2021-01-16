//
//  MusicConfig.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import "MusicConfig.h"
#import "MusicFolderEntity.h"

@implementation MusicConfig

@end


@implementation MusicConfigShare

+ (instancetype)share {
    static dispatch_once_t once;
    static MusicConfigShare * instance;
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
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", FT_docPath, ErrorFolderName]
                                  withIntermediateDirectories:YES attributes:nil error:nil];
        
#if TARGET_OS_MACCATALYST
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", FT_docPath, MusicFolderName]
                                  withIntermediateDirectories:YES attributes:nil error:nil];
#else
        
#endif
        
        NSData * configData = [NSData dataWithContentsOfFile:self.configFilePath];
        if (configData) {
            //_config     = [[MusicConfig alloc] initWithString:[[NSString alloc] initWithData:configData encoding:NSUTF8StringEncoding] error:nil];
            _config = [[MusicConfig alloc] initWithData:configData error:nil];
        } else {
            _config = [MusicConfig new];
            
            _config.playOrder = McPlayOrderRandom;
            
            _config.alertDeleteFile_folder = YES;
        }
        
        
        
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


@end
