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

@implementation MusicPlayListEntity

- (id)init {
    if (self = [super init]) {
        _itemArray = [NSMutableArray<FileEntity> new];
    }
    return self;
}

- (void)sortArray:(MpViewOrder)viewOrder {
    self.viewOrder = viewOrder;
    
    switch(viewOrder) {
        case MpViewOrderAuthorAscend: {
            [self sortAuthorAscending:YES];
            break;
        }
        case MpViewOrderAuthorDescend: {
            [self sortAuthorAscending:NO];
            break;
        }
        case MpViewOrderTitleAscend: {
            [self sortTitleAscending:YES];
            break;
        }
        case MpViewOrderTitleDescend: {
            [self sortTitleAscending:NO];
            break;
        }
        case MpViewOrderCustomAscend: {
            [self sortCustomAscending:YES];
            break;
        }
        case MpViewOrderCustomDescend: {
            [self sortCustomAscending:NO];
            break;
        }
    }
    
}

- (void)sortAuthorAscending:(BOOL)Ascending {
    NSArray * tArray = [self.itemArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        FileEntity * ie1 = obj1;
        FileEntity * ie2 = obj2;
        if (Ascending) {
            return [ie1.musicAuthor localizedCompare:ie2.musicAuthor];
        }else{
            return [ie2.musicAuthor localizedCompare:ie1.musicAuthor];
        }
        //return [ie1.musicAuthor localizedCompare:ie2.musicAuthor] ? NSOrderedAscending : NSOrderedDescending;
    }];
    [self.itemArray removeAllObjects];
    [self.itemArray addObjectsFromArray:tArray];
    
    //for (MusicPlayItemEntity * ie in tArray) {
    //    NSLog(@"作者: %@, 标题:%@", ie.musicAuthor, ie.musicTitle);
    //}
}

- (void)sortTitleAscending:(BOOL)Ascending  {
    NSArray * tArray = [self.itemArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        FileEntity * ie1 = obj1;
        FileEntity * ie2 = obj2;
        if (Ascending) {
            return [ie1.musicTitle localizedCompare:ie2.musicTitle];
        }else{
           return [ie2.musicTitle localizedCompare:ie1.musicTitle];
        }
        //return [ie1.musicTitle localizedCompare:ie2.musicTitle] ? NSOrderedAscending : NSOrderedDescending;
    }];
    [self.itemArray removeAllObjects];
    [self.itemArray addObjectsFromArray:tArray];
    
    //for (MusicPlayItemEntity * ie in tArray) {
    //    NSLog(@"标题:%@, 作者: %@", ie.musicTitle, ie.musicAuthor);
    //}
}

- (void)sortCustomAscending:(BOOL)Ascending  {
    NSArray * tArray = [self.itemArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        FileEntity * ie1 = obj1;
        FileEntity * ie2 = obj2;
        if (Ascending) {
            return ie1.index<ie2.index ? NSOrderedAscending : NSOrderedDescending;
        }else{
            return ie1.index<ie2.index ? NSOrderedDescending : NSOrderedAscending;
        }
    }];
    [self.itemArray removeAllObjects];
    [self.itemArray addObjectsFromArray:tArray];
}

@end

@implementation MusicPlayList

- (id)init {
    if (self = [super init]) {
        _songListArray = [NSMutableArray<MusicPlayListEntity> new];
        //_localItemArray = [NSMutableArray<MusicPlayListEntity> new];
    }
    return self;
}

@end
