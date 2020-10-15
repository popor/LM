//
//  FileEntity.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import <PoporJsonModel/PoporJsonModel.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * WFIgnoreFile = @".DS_Store";

@protocol FileEntity;
@interface FileEntity : PoporJsonModel

@property (nonatomic, copy  ) NSString * folderName;
@property (nonatomic, copy  ) NSString * fileName;
@property (nonatomic, copy  ) NSString * fileNameDeleteExtension;
@property (nonatomic, copy  ) NSString * filePath;
@property (nonatomic, copy  ) NSMutableArray<FileEntity, Ignore> * itemArray;

//----- 音乐文件;
@property (nonatomic, copy  ) NSString * musicAuthor;
@property (nonatomic, copy  ) NSString * musicName;
@property (nonatomic        ) CGFloat    musicDuration;
@property (nonatomic, copy  ) UIImage  * musicCover;

// 额外参数
@property (nonatomic, getter=isAvailable) BOOL available; // 是否还存在
@property (nonatomic        ) NSInteger index;

@property (nonatomic, getter=isFolder) BOOL folder;


+ (UIImage *)mp3CoverImage:(NSString *)filePath;


@end

NS_ASSUME_NONNULL_END
