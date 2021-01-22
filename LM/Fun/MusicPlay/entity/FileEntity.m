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
#import "MusicPlayTool.h"

@implementation FileEntity

- (id)copyWithZone:(NSZone *)zone {
    FileEntity *entity = [[[self class] alloc] init]; // <== 注意这里
    entity.folderName  = self.folderName;
    entity.fileName    = self.fileName;
    entity.fileType    = self.fileType;
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
        coverImage = [MusicPlayTool share].defaultCoverImage;
    }
    return coverImage;
}

- (void)updateFileFolder:(NSString *)folderName fileType:(FileType)fileType FileName:(NSString *)fileName {
    self.folderName = folderName;
    self.fileName   = fileName;
    self.fileType   = fileType;
    self.filePath   = [NSString stringWithFormat:@"%@/%@", folderName, fileName];
    
    if (fileType == FileType_folder || fileType == FileType_virtualFolder) {
        
    } else {
        if (fileName.pathExtension.length > 0) {
            self.fileNameDeleteExtension = [fileName substringToIndex:fileName.length - fileName.pathExtension.length - 1];
            self.extension = fileName.pathExtension.lowercaseString;
        } else {
            self.fileNameDeleteExtension = fileName;
        }
        
        NSRange range = [self.fileNameDeleteExtension rangeOfString:@"-"];
        if (range.location > 0 && range.length > 0) {
            self.songName   = [self.fileNameDeleteExtension substringFromIndex:range.location + range.length];
            self.authorName = [self.fileNameDeleteExtension substringToIndex:range.location];
            
            self.songName   = [self.songName replaceWithREG:@"^\\s+" newString:@""];
            self.authorName = [self.authorName replaceWithREG:@"\\s+$" newString:@""];
        }else{
            self.songName   = self.fileNameDeleteExtension;
            self.authorName = @"";
        }
    }
}

- (BOOL)isFolder {
    if (self.fileType == FileType_folder || self.fileType == FileType_virtualFolder) {
        return YES;
    } else {
        return NO;
    }
}

@end
