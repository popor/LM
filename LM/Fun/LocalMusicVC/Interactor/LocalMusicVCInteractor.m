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

@end

@implementation LocalMusicVCInteractor

- (id)init {
    if (self = [super init]) {
        self.mplShare = [MusicPlayListEntityShare share];
    }
    return self;
}

- (void)initData {
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
#if TARGET_OS_MACCATALYST
    self.mplShare.diskFolderArray = [FileTool getArrayAtPath:MusicFolderName type:FileType_folder];
#else
    self.mplShare.songFolderArray = [FileTool getArrayAtPath:nil type:FileType_folder];
#endif
    FileEntity * folderEntity_error;
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
        
        NSMutableArray<FileEntity, Ignore> * itemArray = [FileTool getArrayAtPath:[NSString stringWithFormat:@"%@/%@", folderEntity.folderName, folderEntity.fileName] type:FileType_file];
        
        // 排序
        NSArray *result = [itemArray sortedArrayUsingComparator:^NSComparisonResult(FileEntity * _Nonnull obj1, FileEntity * _Nonnull obj2) {
            NSRange string1Range = NSMakeRange(0, [obj1.fileNameDeleteExtension length]);
            return [obj1.fileNameDeleteExtension compare:obj2.fileNameDeleteExtension options:0 range:string1Range locale:locale];
        }];
        folderEntity.itemArray = result.mutableCopy;
        
        // 检查异常文件夹
        if ([folderEntity.fileName isEqualToString:ErrorFolderName]
            ) {
            if (folderEntity.itemArray.count == 0) {
                // ios 假如Error文件夹为空的话 忽略
                
                [self.mplShare.songFolderArray removeObject:folderEntity];
                continue;
            } else {
                folderEntity_error = folderEntity;
            }
        }
        
        i++;
    }
    
    NSArray *result = [self.mplShare.songFolderArray sortedArrayUsingComparator:^NSComparisonResult(FileEntity * _Nonnull obj1, FileEntity * _Nonnull obj2) {
        
        return [obj1.fileNameDeleteExtension compare:obj2.fileNameDeleteExtension]; //升序
    }];
    self.mplShare.songFolderArray = result.mutableCopy;
    if (folderEntity_error) {
        [self.mplShare.songFolderArray removeObject:folderEntity_error];
        [self.mplShare.songFolderArray addObject:folderEntity_error];
    }
    
    self.mplShare.allFileEntity = nil;
    self.mplShare.allFileEntity = ({
        FileEntity * fileEntity = [FileEntity new];
        fileEntity.fileName  = @"全部";
        fileEntity.fileID    = KRootCellFolderName_all;
        
        fileEntity.fileType  = FileType_virtualFolder;
        fileEntity.itemArray = [NSMutableArray<FileEntity, Ignore> new];
        
        for (FileEntity * fe in self.mplShare.songFolderArray) {
            if (fe == folderEntity_error) {
                continue;
            } else {
                [fileEntity.itemArray addObjectsFromArray:fe.itemArray];
            }
        }
        
        // 插入字典
        [self.mplShare.allFileEntityDic removeAllObjects];
        for (FileEntity * fe in fileEntity.itemArray) {
            if (fe.authorName.length >0) {
                fe.pinYinAuthor = [fe.authorName substringToIndex:1];
                fe.pinYinAuthor = [self firstCharactor:fe.pinYinAuthor];
            }
            
            if (fe.songName.length >0) {
                fe.pinYinSong = [fe.songName substringToIndex:1];
                fe.pinYinSong = [self firstCharactor:fe.pinYinSong];
            }
            
            self.mplShare.allFileEntityDic[fe.filePath] = fe;
        }
        
        // 排序
        NSArray *result = [fileEntity.itemArray sortedArrayUsingComparator:^NSComparisonResult(FileEntity * _Nonnull obj1, FileEntity * _Nonnull obj2) {
            NSRange string1Range = NSMakeRange(0, 1);
            //            NSString *
            return [obj1.pinYinAuthor compare:obj2.pinYinAuthor options:0 range:string1Range locale:locale];
            //return [obj1.pinYinAuthor compare:obj1.pinYinAuthor]; //升序
        }];
        fileEntity.itemArray = result.mutableCopy;
        
        fileEntity;
    });
    
    self.localArray = self.mplShare.songFolderArray;
    
    [self freshFavFolderEvent];
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
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return [pinYin substringToIndex:1];
}

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
