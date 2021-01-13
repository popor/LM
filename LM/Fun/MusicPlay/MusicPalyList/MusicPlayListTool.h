//
//  MusicPlayListTool.h
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MusicPlayList.h"
#import "MusicConfig.h"

NS_ASSUME_NONNULL_BEGIN

#define MpltShare [MusicPlayListTool share]

static NSString * ConfigFolderName    = @"Config";
static NSString * MusicFolderName     = @"Music";
static NSString * ArtworkFolderName   = @"Artwork";// 插图
static NSString * DownloadFolderName  = @"Download";// 下载
static NSString * ErrorFolderName     = @"Error";// 错误

@interface MusicPlayListTool : NSObject


+ (MusicPlayListTool *)share;

@property (nonatomic, strong) MusicConfig   * config;

+ (NSString *)downloadFolderPath;

+ (NSString *)errorFolderPath;

@end

NS_ASSUME_NONNULL_END
