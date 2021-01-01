//
//  FileEntity.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import "FileEntity.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@implementation FileEntity

- (id)copyWithZone:(NSZone *)zone {
    FileEntity *entity = [[[self class] alloc] init]; // <== 注意这里
    entity.folderName  = self.folderName;
    entity.fileName    = self.fileName;
    entity.folder      = self.isFolder;
    entity.itemArray   = [self.itemArray mutableCopy];
    
    return entity;
}

+ (UIImage *)mp3CoverImage:(NSString *)filePath {
    NSString * path = [NSString stringWithFormat:@"%@/%@", FT_docPath, filePath];
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

- (void)updateFileFolder:(NSString *)folderName isFolder:(BOOL)isFolder FileName:(NSString *)fileName {
    self.folderName = folderName;
    self.fileName   = fileName;
    self.folder     = isFolder;
    self.filePath   = [NSString stringWithFormat:@"%@/%@", folderName, fileName];
    
    if (isFolder) {
        
    } else {
        if (fileName.pathExtension.length > 0) {
            self.fileNameDeleteExtension = [fileName substringToIndex:fileName.length - fileName.pathExtension.length - 1];
        } else {
            self.fileNameDeleteExtension = fileName;
        }
        
        NSRange range = [self.fileNameDeleteExtension rangeOfString:@"-"];
        if (range.location > 0 && range.length > 0) {
            self.musicName   = [self.fileNameDeleteExtension substringFromIndex:range.location + range.length];
            self.musicAuthor = [self.fileNameDeleteExtension substringToIndex:range.location];
            
            self.musicName   = [self.musicName replaceWithREG:@"^\\s+" newString:@""];
            self.musicAuthor = [self.musicAuthor replaceWithREG:@"\\s+$" newString:@""];
        }else{
            self.musicName   = self.fileNameDeleteExtension;
            self.musicAuthor = @"";
        }
    }
}

@end
