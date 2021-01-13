//
//  MusicPlayListEntity.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import "MusicPlayListEntity.h"

#import "MusicFolderEntity.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@implementation MusicPlayListEntity

- (id)init {
    if (self = [super init]) {
        _songListArray = [NSMutableArray<FileEntity> new];
        //_localItemArray = [NSMutableArray<MusicPlayListEntity> new];
    }
    return self;
}

@end


@implementation MusicPlayListEntityShare

+ (instancetype)share {
    static dispatch_once_t once;
    static MusicPlayListEntityShare * instance;
    dispatch_once(&once, ^{
        instance = [MusicPlayListEntityShare new];
        [instance resumeFavRecordData];
        instance.allFileEntityDic = [NSMutableDictionary new];
        instance.currentTempList  = [NSMutableArray<FileEntity> new];
    });
    return instance;
}

- (void)resumeFavRecordData {
    NSData * listData = [NSData dataWithContentsOfFile:[[self class] listFilePath]];
    if (listData) {
        self.songFavListEntity = [[MusicPlayListEntity alloc] initWithData:listData error:nil];
    } else {
        self.songFavListEntity = [MusicPlayListEntity new];
    }
}

- (void)updateSongList {
    [self.songFavListEntity.toJSONData writeToFile:[[self class] listFilePath] atomically:YES];
    
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
