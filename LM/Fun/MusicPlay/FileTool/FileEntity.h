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

typedef NS_ENUM(NSInteger, FileType) {
    FileType_folder,
    FileType_file,
    FileType_virtualFolder,
};

@protocol FileEntity;
@interface FileEntity : PoporJsonModel

@property (nonatomic        ) FileType   fileType;
@property (nonatomic, copy  ) NSString * folderName;
@property (nonatomic, copy  ) NSString * fileName;
@property (nonatomic, copy  ) NSString * fileNameDeleteExtension;
@property (nonatomic, copy  ) NSString * filePath;
@property (nonatomic, strong) NSMutableArray<FileEntity, Ignore> * itemArray;

//----- 音乐文件;
@property (nonatomic, copy  ) NSString * musicAuthor; // 本APP 的歌手和歌名, 并没有读取mp3的文件属性, 只是根据文件名字分析出来.
@property (nonatomic, copy  ) NSString * musicName;
@property (nonatomic        ) CGFloat    musicDuration;
@property (nonatomic, copy  ) UIImage  * musicCover;

// 额外参数
@property (nonatomic, getter=isAvailable) BOOL available; // 是否还存在
@property (nonatomic        ) NSInteger index;

- (BOOL)isFolder;

+ (UIImage *)mp3CoverImage:(NSString *)filePath;

- (void)updateFileFolder:(NSString *)folderName fileType:(FileType)fileType FileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
