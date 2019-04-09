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

@implementation MusicPlayItemEntity

+ (MusicPlayItemEntity *)initWithFileEntity:(FileEntity *)fileEntity {
    MusicPlayItemEntity * item = [MusicPlayItemEntity new];
    item.filePath    = fileEntity.filePath;
    item.fileName    = fileEntity.fileName;
    item.musicTitle  = fileEntity.musicTitle;
    item.musicAuthor = fileEntity.musicAuthor;
    
    return item;
}

- (UIImage *)coverImage {
    NSString * path = [NSString stringWithFormat:@"%@/%@", MpltShare.docPath, self.filePath];
    NSURL * url     = [NSURL fileURLWithPath:path];
    UIImage * coverImage;
    
    AVURLAsset *avURLAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
    for (NSString * format in [avURLAsset availableMetadataFormats]){
        for (AVMetadataItem *metadata in [avURLAsset metadataForFormat:format]){
            // NSLog(@"metadata.commonKey: %@", metadata.commonKey);
            // if([metadata.commonKey isEqualToString:@"title"]){
            //     NSString *title = (NSString *)metadata.value;//提取歌曲名
            // }
            if([metadata.commonKey isEqualToString:@"artwork"]){
                NSData*data = [metadata.value copyWithZone:nil];
                coverImage = [UIImage imageWithData:data];
                //MPMediaItemArtwork *media = [[MPMediaItemArtwork alloc] initWithImage:coverImage];
                //[songInfo setObject:media forKey:MPMediaItemPropertyArtwork];
            }//还可以提取其他所需的信息
        }
    }
    if (!coverImage) {
        coverImage = [UIImage imageNamed:@"music_placeholder"];
    }
    return coverImage;
}

@end

@implementation MusicPlayListEntity

- (id)init {
    if (self = [super init]) {
        _array = [NSMutableArray new];
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"array" : [MusicPlayItemEntity class]};
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
    NSArray * tArray = [self.array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        MusicPlayItemEntity * ie1 = obj1;
        MusicPlayItemEntity * ie2 = obj2;
        if (Ascending) {
            return [ie1.musicAuthor localizedCompare:ie2.musicAuthor];
        }else{
            return [ie2.musicAuthor localizedCompare:ie1.musicAuthor];
        }
        //return [ie1.musicAuthor localizedCompare:ie2.musicAuthor] ? NSOrderedAscending : NSOrderedDescending;
    }];
    [self.array removeAllObjects];
    [self.array addObjectsFromArray:tArray];
    
    //for (MusicPlayItemEntity * ie in tArray) {
    //    NSLog(@"作者: %@, 标题:%@", ie.musicAuthor, ie.musicTitle);
    //}
}

- (void)sortTitleAscending:(BOOL)Ascending  {
    NSArray * tArray = [self.array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        MusicPlayItemEntity * ie1 = obj1;
        MusicPlayItemEntity * ie2 = obj2;
        if (Ascending) {
            return [ie1.musicTitle localizedCompare:ie2.musicTitle];
        }else{
           return [ie2.musicTitle localizedCompare:ie1.musicTitle];
        }
        //return [ie1.musicTitle localizedCompare:ie2.musicTitle] ? NSOrderedAscending : NSOrderedDescending;
    }];
    [self.array removeAllObjects];
    [self.array addObjectsFromArray:tArray];
    
    //for (MusicPlayItemEntity * ie in tArray) {
    //    NSLog(@"标题:%@, 作者: %@", ie.musicTitle, ie.musicAuthor);
    //}
}

- (void)sortCustomAscending:(BOOL)Ascending  {
    NSArray * tArray = [self.array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        MusicPlayItemEntity * ie1 = obj1;
        MusicPlayItemEntity * ie2 = obj2;
        if (Ascending) {
            return ie1.index<ie2.index ? NSOrderedAscending : NSOrderedDescending;
        }else{
            return ie1.index<ie2.index ? NSOrderedDescending : NSOrderedAscending;
        }
    }];
    [self.array removeAllObjects];
    [self.array addObjectsFromArray:tArray];
}

@end

@implementation MusicPlayList

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"array" : [MusicPlayListEntity class]};
}

@end
