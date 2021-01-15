//
//  LocalMusicVCInteractor.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import "LocalMusicVCInteractor.h"
#import "FileTool.h"
#import "MusicFolderEntity.h"
#import "LrcPrefix.h"
#import "MusicFolderEntity.h"

@interface LocalMusicVCInteractor ()
@property (nonatomic, weak  ) FileEntity * folderEntity_error;
@property (nonatomic, weak  ) FileEntity * folderEntity_download;
@end

@implementation LocalMusicVCInteractor

- (id)init {
    if (self = [super init]) {
        self.mplShare = [MusicPlayListEntityShare share];
    }
    return self;
}

- (void)initData {
    
#if TARGET_OS_MACCATALYST
    self.mplShare.songFolderArray = [FileTool getArrayAtPath:MusicFolderName type:FileType_folder];
#else
    self.mplShare.songFolderArray = [FileTool getArrayAtPath:nil type:FileType_folder];
#endif

    for (NSInteger i = 0; i<self.mplShare.songFolderArray.count;) {
        FileEntity * folderEntity = self.mplShare.songFolderArray[i];
        
        // 初始化文件夹名称
        folderEntity.fileID = folderEntity.fileName;
#if TARGET_OS_MACCATALYST
        
#else
        if (   [folderEntity.fileName isEqualToString:LrcFolderName]
            || [folderEntity.fileName isEqualToString:LrcListFolderName]
            || [folderEntity.fileName isEqualToString:ConfigFolderName]
            || [folderEntity.fileName isEqualToString:ArtworkFolderName])
        {
            // ios 忽略4个文件夹
            [self.mplShare.songFolderArray removeObject:folderEntity];
            continue;
        }
#endif
        
        folderEntity.itemArray = [FileTool getArrayAtPath:[NSString stringWithFormat:@"%@/%@", folderEntity.folderName, folderEntity.fileName] type:FileType_file];
        // 检查异常文件夹
        if ([folderEntity.fileName isEqualToString:ErrorFolderName]
            ) {
            if (folderEntity.itemArray.count == 0) {
                // ios 假如Error文件夹为空的话 忽略
                
                [self.mplShare.songFolderArray removeObject:folderEntity];
                continue;
            } else {
                self.folderEntity_error = folderEntity;
            }
        }
        
        // 设置下载文件夹
        if ([folderEntity.fileName isEqualToString:DownloadFolderName]) {
            self.folderEntity_download = folderEntity;
        }
        
        i++;
    }
    
    {   // 文件夹排序
        NSArray *result = [self.mplShare.songFolderArray sortedArrayUsingComparator:^NSComparisonResult(FileEntity * _Nonnull obj1, FileEntity * _Nonnull obj2) {
            return [obj1.fileName compare:obj2.fileName]; //升序
        }];
        self.mplShare.songFolderArray = result.mutableCopy;
        
        // 手动更新顺序
        if (self.folderEntity_download) {
            [self.mplShare.songFolderArray removeObject:self.folderEntity_download];
            [self.mplShare.songFolderArray insertObject:self.folderEntity_download atIndex:0];
        }
        if (self.folderEntity_error) {
            [self.mplShare.songFolderArray removeObject:self.folderEntity_error];
            [self.mplShare.songFolderArray addObject:self.folderEntity_error];
        }
    }
    // 更新设置全部文件
    [self updateAllFileEntity];
    
    self.localArray = self.mplShare.songFolderArray;
    
    [self sortSongArray];
    
    [self freshFavFolderEvent];
}

// 更新设置全部文件
- (void)updateAllFileEntity {
    
    self.mplShare.allFileEntity = nil;
    self.mplShare.allFileEntity = ({
        FileEntity * fileEntity = [FileEntity new];
        fileEntity.fileName  = @"全部";
        fileEntity.fileID    = KRootCellFolderName_all;
        
        fileEntity.fileType  = FileType_virtualFolder;
        fileEntity.itemArray = [NSMutableArray<FileEntity, Ignore> new];
        
        for (FileEntity * fe in self.mplShare.songFolderArray) {
            if (fe == self.folderEntity_error) {
                continue;
            } else {
                [fileEntity.itemArray addObjectsFromArray:fe.itemArray];
            }
        }
        
        // 插入字典
        [self.mplShare.allFileEntityDic removeAllObjects];
        for (FileEntity * fe in fileEntity.itemArray) {
            if (fe.authorName.length >0) {
                fe.pinYinAuthor = [self firstCharactor:fe.authorName];
                fe.pinYinAuthorFirst = [fe.pinYinAuthor substringToIndex:1];
            }
            
            if (fe.songName.length >0) {
                fe.pinYinSong = [self firstCharactor:fe.songName];
                fe.pinYinSongFirst = [fe.pinYinSong substringToIndex:1];
            }
            fe.pinYinAll = [NSString stringWithFormat:@"%@%@", fe.pinYinAuthor, fe.pinYinSong];
            
            self.mplShare.allFileEntityDic[fe.filePath] = fe;
        }
        
        fileEntity;
    });
}

- (void)sortSongArray {
    // 全部文件夹
    [self sortFileEntityArray:self.mplShare.allFileEntity.itemArray finish:^(FileSortType sortType, NSArray *sortArray) {
        self.mplShare.allFileEntity.sortType  = sortType;
        self.mplShare.allFileEntity.itemArray = sortArray.mutableCopy;
    }];
    
    // 物理文件夹
    for (FileEntity * folderEntity in self.localArray) {
        [self sortFileEntityArray:folderEntity.itemArray finish:^(FileSortType sortType, NSArray *sortArray) {
            folderEntity.sortType  = sortType;
            folderEntity.itemArray = sortArray.mutableCopy;
        }];
    }
}

- (void)sortFileEntityArray:(NSArray<FileEntity> *)fileEntityArray finish:(void (^ _Nonnull)(FileSortType sortType, NSArray * sortArray))block {
    NSLocale * locale    = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    // 文件内容排序
    BOOL sameAuthor = YES;
    FileEntity * firstFE  = fileEntityArray.firstObject;
    NSString * lastAuthor = firstFE.pinYinAuthor;
    for (FileEntity * songFE in fileEntityArray) {
        if (![lastAuthor isEqualToString:songFE.pinYinAuthor]) {
            sameAuthor = NO;
            break;
        }
    }
    
    if (sameAuthor) {
        NSRange string1Range = NSMakeRange(0, 1);
        NSArray *result = [fileEntityArray sortedArrayUsingComparator:^NSComparisonResult(FileEntity * _Nonnull obj1, FileEntity * _Nonnull obj2) {
            return [obj1.pinYinSong compare:obj2.pinYinSong options:0 range:string1Range locale:locale];
        }];
        block(FileSortType_song, result);
    } else {
        NSArray *result = [fileEntityArray sortedArrayUsingComparator:^NSComparisonResult(FileEntity * _Nonnull obj1, FileEntity * _Nonnull obj2) {
            NSRange string1Range = NSMakeRange(0, obj1.pinYinAll.length);
            return [obj1.pinYinAll compare:obj2.pinYinAll options:0 range:string1Range locale:locale];
        }];
        block(FileSortType_author, result);
    }
}

#pragma mark - VCDataSource
- (void)freshFavFolderEvent {
    self.mplShare.songListArray = [NSMutableArray<FileEntity> new];
    
    for (FileEntity *fe in self.mplShare.songFavListEntity.songListArray) {
        
        FileEntity * listFE = [FileEntity new];
        listFE.fileName   = fe.fileName;
        listFE.fileID     = fe.fileID;
        listFE.fileType   = FileType_virtualFolder;
        listFE.itemArray  = [NSMutableArray<FileEntity> new];
        [self.mplShare.songListArray addObject:listFE];
        
        for (FileEntity *fe0 in fe.itemArray) {
            FileEntity *fe1 = self.mplShare.allFileEntityDic[fe0.filePath];
            [listFE.itemArray addObject:fe1];
        }
    }
    // 重置记录list, 使得他们使用同一个地址
    [self.mplShare.songFavListEntity.songListArray removeAllObjects];
    [self.mplShare.songFavListEntity.songListArray addObjectsFromArray:self.mplShare.songListArray];
    
    [self.mplShare.songListArray insertObject:self.mplShare.allFileEntity atIndex:0];
}

//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
- (NSString *)firstCharactor:(NSString *)aString {
    BOOL isLetter   = [self IsLetter:aString];
    NSString * reg0 = @"(\\w)\\w*\\s*";
    NSString * reg1 = @"$1";
    
    NSString *pinYin;
    if (isLetter) {
        // 英语的话, 只显示前几个, 防止有多个歌手的情况.
        
        pinYin = [aString substringToIndex:MIN(3, aString.length)];
        //NSLog(@"%@ --> %@", aString, pinYin);
    } else {
        // 汉语不考虑这种情况
        
        //转成了可变字符串
        NSMutableString * str = [NSMutableString stringWithString:aString];
        //先转换为带声调的拼音
        CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin,  NO);
        //再转换为不带声调的拼音
        CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics,NO);
        //转化为大写拼音
        //pinYin = [str capitalizedString];
        //NSLog(@" %@ --> %@", aString, pinYin);
        
        pinYin = [str replaceWithREG:reg0 newString:reg1];
        
        if (![self IsLetter:pinYin]) {
            pinYin = @"#";
        }
        //NSLog(@"    %@ --> %@", aString, pinYin);
    }
    
    if (pinYin.length == 0) {
        pinYin = @"#";
    }
    
    return [pinYin uppercaseString];
}

// 只检查第一个文字
- (BOOL)IsLetter:(NSString *)str {
    BOOL isLetter = YES;
    if (str.length > 0) {
        int a = [str characterAtIndex:0];
        if ((a >64 && a<91)
            || (a >96 && a<123))
        {
            isLetter = YES;
        } else {
            isLetter = NO;
        }
    }
    return isLetter;
}

//- (BOOL)IsChinese:(NSString *)str {
//    BOOL isChinese = YES;
//    for(int i=0; i< [str length];i++){
//        int a = [str characterAtIndex:i];
//        if( a >= 0x4e00 && a <= 0x9fff) {
//
//        }else{
//            isChinese = NO;
//        }
//    }
//    return isChinese;
//}

- (void)addListName:(NSString *)name {
    FileEntity * list = [FileEntity new];
    list.fileName   = name;
    list.fileID     = [NSString getUUID];
    [self.mplShare.songFavListEntity.songListArray addObject:list];
    [self updateSongList];
}

- (void)updateSongList {
    [self.mplShare updateSongList];
}

@end
