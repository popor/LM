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

@end

@implementation MusicPlayList

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"array" : [MusicPlayListEntity class]};
}

@end
