//
//  MusicPlayList.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import "MusicPlayList.h"

#import "MusicFolderEntity.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@implementation MusicPlayList

- (id)init {
    if (self = [super init]) {
        _songListArray = [NSMutableArray<FileEntity> new];
        //_localItemArray = [NSMutableArray<MusicPlayListEntity> new];
    }
    return self;
}

@end


@implementation MusicPlayListShare

+ (instancetype)share {
    static dispatch_once_t once;
    static MusicPlayListShare * instance;
    dispatch_once(&once, ^{
        instance = [MusicPlayListShare new];
        [instance resumeFavRecordData];
        instance.allFileEntityDic = [NSMutableDictionary new];
        instance.currentTempList  = [NSMutableArray<FileEntity> new];
    });
    return instance;
}

- (void)resumeFavRecordData {
    NSData * listData   = [NSData dataWithContentsOfFile:[[self class] listFilePath]];
    if (listData) {
        //_list = [[MusicPlayList alloc] initWithString:[[NSString alloc] initWithData:listData encoding:NSUTF8StringEncoding] error:nil];
        self.list = [[MusicPlayList alloc] initWithData:listData error:nil];
    } else {
        self.list = [MusicPlayList new];
    }
}

- (void)updateSongList {
    [self.list.toJSONData writeToFile:[[self class] listFilePath] atomically:YES];
    
    //    NSString * path = [self listFilePath];
    //    NSString * json = [self.list toJSONString];
    //    [json writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (NSString *)listFilePath {
    static NSString * text;
    if (!text) {
        text = [NSString stringWithFormat:@"%@/%@/%@.json", FT_docPath, ConfigFolderName, LmPlayListKey];
    }
    return text;
}

@end
