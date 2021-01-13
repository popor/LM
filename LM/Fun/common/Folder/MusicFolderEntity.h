//
//  MusicFolderEntity.h
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * ConfigFolderName    = @"Config";
static NSString * MusicFolderName     = @"Music";
static NSString * ArtworkFolderName   = @"Artwork";// 插图
static NSString * DownloadFolderName  = @"Download";// 下载
static NSString * ErrorFolderName     = @"Error";// 错误

@interface MusicFolderEntity : NSObject

+ (NSString *)downloadFolderPath;

+ (NSString *)errorFolderPath;

@end

NS_ASSUME_NONNULL_END
