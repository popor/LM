//
//  FileEntity.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import <PoporJsonModel/PoporJsonModel.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * WFIgnoreFile    = @".DS_Store";
static NSString * KFolderName_all = @".allFile.";

typedef NS_ENUM(NSInteger, FileType) {
    FileType_folder,
    FileType_file,
    FileType_virtualFolder,
};

typedef NS_ENUM(NSInteger, FileSortType) {
    FileSortType_null,
    FileSortType_author,
    FileSortType_song,
};


@protocol FileEntity;
@interface FileEntity : PoporJsonModel

@property (nonatomic        ) FileType fileType;
@property (nonatomic, copy  ) NSString * fileID;

@property (nonatomic, copy  ) NSString<Ignore> * folderName;
@property (nonatomic, copy  ) NSString * fileName;
@property (nonatomic, copy  ) NSString<Ignore> * fileNameDeleteExtension;
@property (nonatomic, copy  ) NSString<Ignore> * extension; // 后缀
@property (nonatomic, copy  ) NSString * filePath;
@property (nonatomic, strong) NSMutableArray<FileEntity> * itemArray; //Ignore

//----- 音乐文件;
@property (nonatomic, copy  ) NSString<Ignore> * authorName; // 本APP 的歌手和歌名, 并没有读取mp3的文件属性, 只是根据文件名字分析出来.
@property (nonatomic, copy  ) NSString<Ignore> * songName;
@property (nonatomic, copy  ) UIImage <Ignore> * musicCover;
@property (nonatomic        ) CGFloat musicDuration;

// 额外参数 - 排序
@property (nonatomic        ) FileSortType       sortType;     // 排序是歌手还是歌曲.
@property (nonatomic, copy  ) NSString<Ignore> * pinYinAuthor;
@property (nonatomic, copy  ) NSString<Ignore> * pinYinAuthorFirst;

@property (nonatomic, copy  ) NSString<Ignore> * pinYinSong;
@property (nonatomic, copy  ) NSString<Ignore> * pinYinSongFirst;

@property (nonatomic, copy  ) NSString<Ignore> * pinYinAll;

// 额外参数 - 文件夹
//@property (nonatomic, copy  ) NSString<Ignore> * iconName;

- (BOOL)isFolder;

+ (UIImage *)mp3CoverImage:(NSString *)filePath;

- (void)updateFileFolder:(NSString *)folderName fileType:(FileType)fileType FileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
