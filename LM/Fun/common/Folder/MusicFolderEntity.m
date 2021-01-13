//
//  MusicFolderEntity.m
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.
//

#import "MusicFolderEntity.h"

@interface MusicFolderEntity ()

@end

@implementation MusicFolderEntity

+ (void)load {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        // 生成文件夹
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
        
    });
}

//// 插图路径
//- (NSString *)artworkFolderPath {
//    static NSString * text;
//    if (!text) {
//        text = [NSString stringWithFormat:@"%@/%@", FT_docPath, ArtworkFolderName];
//    }
//    return text;
//}

+ (NSString *)downloadFolderPath {
    static NSString * text;
    if (!text) {
        text = [NSString stringWithFormat:@"%@/%@", FT_docPath, DownloadFolderName];
    }
    return text;
}

+ (NSString *)errorFolderPath {
    static NSString * text;
    if (!text) {
        text = [NSString stringWithFormat:@"%@/%@", FT_docPath, ErrorFolderName];
    }
    return text;
}

@end
