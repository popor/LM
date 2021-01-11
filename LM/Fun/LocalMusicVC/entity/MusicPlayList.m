//
//  MusicPlayList.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import "MusicPlayList.h"

#import "MusicPlayListTool.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

//@implementation MusicPlayListEntity
//
//- (id)init {
//    if (self = [super init]) {
//        _itemArray = [NSMutableArray<FileEntity> new];
//    }
//    return self;
//}
//
////- (void)sortArray:(MpViewOrder)viewOrder {
////    self.viewOrder = viewOrder;
////    
////    switch(viewOrder) {
////        case MpViewOrderAuthorAscend: {
////            [self sortAuthorAscending:YES];
////            break;
////        }
////        case MpViewOrderAuthorDescend: {
////            [self sortAuthorAscending:NO];
////            break;
////        }
////        case MpViewOrderTitleAscend: {
////            [self sortTitleAscending:YES];
////            break;
////        }
////        case MpViewOrderTitleDescend: {
////            [self sortTitleAscending:NO];
////            break;
////        }
////        case MpViewOrderCustomAscend: {
////            [self sortCustomAscending:YES];
////            break;
////        }
////        case MpViewOrderCustomDescend: {
////            [self sortCustomAscending:NO];
////            break;
////        }
////    }
////    
////}
////
////- (void)sortAuthorAscending:(BOOL)Ascending {
////    NSArray * tArray = [self.itemArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
////        FileEntity * ie1 = obj1;
////        FileEntity * ie2 = obj2;
////        if (Ascending) {
////            return [ie1.musicAuthor localizedCompare:ie2.musicAuthor];
////        }else{
////            return [ie2.musicAuthor localizedCompare:ie1.musicAuthor];
////        }
////        //return [ie1.musicAuthor localizedCompare:ie2.musicAuthor] ? NSOrderedAscending : NSOrderedDescending;
////    }];
////    [self.itemArray removeAllObjects];
////    [self.itemArray addObjectsFromArray:tArray];
////    
////    //for (MusicPlayItemEntity * ie in tArray) {
////    //    NSLog(@"作者: %@, 标题:%@", ie.musicAuthor, ie.musicTitle);
////    //}
////}
////
////- (void)sortTitleAscending:(BOOL)Ascending  {
////    NSArray * tArray = [self.itemArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
////        FileEntity * ie1 = obj1;
////        FileEntity * ie2 = obj2;
////        if (Ascending) {
////            return [ie1.musicName localizedCompare:ie2.musicName];
////        }else{
////           return [ie2.musicName localizedCompare:ie1.musicName];
////        }
////        //return [ie1.musicTitle localizedCompare:ie2.musicTitle] ? NSOrderedAscending : NSOrderedDescending;
////    }];
////    [self.itemArray removeAllObjects];
////    [self.itemArray addObjectsFromArray:tArray];
////    
////    //for (MusicPlayItemEntity * ie in tArray) {
////    //    NSLog(@"标题:%@, 作者: %@", ie.musicTitle, ie.musicAuthor);
////    //}
////}
////
////- (void)sortCustomAscending:(BOOL)Ascending  {
////    NSArray * tArray = [self.itemArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
////        FileEntity * ie1 = obj1;
////        FileEntity * ie2 = obj2;
////        if (Ascending) {
////            return ie1.index<ie2.index ? NSOrderedAscending : NSOrderedDescending;
////        }else{
////            return ie1.index<ie2.index ? NSOrderedDescending : NSOrderedAscending;
////        }
////    }];
////    [self.itemArray removeAllObjects];
////    [self.itemArray addObjectsFromArray:tArray];
////}
//
//@end
//
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
    for (FileEntity * fe in self.list.songListArray) {
        NSLog(@"count: %li", fe.itemArray.count);
    }
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
