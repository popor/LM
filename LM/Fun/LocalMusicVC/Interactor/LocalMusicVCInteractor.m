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

@property (nonatomic, strong) NSMutableArray<FileEntity> * folderArray;

@end

@implementation LocalMusicVCInteractor

- (id)init {
    if (self = [super init]) {
        self.mplShare = [MusicPlayListShare share];
    }
    return self;
}

- (void)initData {
#if TARGET_OS_MACCATALYST
    self.folderArray = [FileTool getArrayAtPath:MusicFolderName type:FileType_folder];
#else
    self.folderArray = [FileTool getArrayAtPath:nil type:FileType_folder];
#endif
    FileEntity * folderEntity_error;
    for (NSInteger i = 0; i<self.folderArray.count;) {
        FileEntity * folderEntity = self.folderArray[i];
        
        // 初始化文件夹名称
        folderEntity.fileID = folderEntity.fileName;
#if TARGET_OS_MACCATALYST
        
#else
        if ([folderEntity.fileName isEqualToString:LrcFolderName]
            || [folderEntity.fileName isEqualToString:LrcListFolderName]
            || [folderEntity.fileName isEqualToString:ConfigFolderName]
            || [folderEntity.fileName isEqualToString:ArtworkFolderName])
            {
            // ios 忽略4个文件夹
            [self.folderArray removeObject:folderEntity];
            continue;
        }
#endif
        
        NSMutableArray<FileEntity, Ignore> * itemArray = [FileTool getArrayAtPath:[NSString stringWithFormat:@"%@/%@", folderEntity.folderName, folderEntity.fileName] type:FileType_file];
        
        // 排序
        NSArray *result = [itemArray sortedArrayUsingComparator:^NSComparisonResult(FileEntity * _Nonnull obj1, FileEntity * _Nonnull obj2) {
            return [obj1.fileNameDeleteExtension compare:obj2.fileNameDeleteExtension]; //升序
        }];
        folderEntity.itemArray = result.mutableCopy;
        
        // 检查异常文件夹
        if ([folderEntity.fileName isEqualToString:ErrorFolderName]
            ) {
            if (folderEntity.itemArray.count == 0) {
                // ios 假如Error文件夹为空的话 忽略
                
                [self.folderArray removeObject:folderEntity];
                continue;
            } else {
                folderEntity_error = folderEntity;
            }
        }
        
        i++;
    }
    
    NSArray *result = [self.folderArray sortedArrayUsingComparator:^NSComparisonResult(FileEntity * _Nonnull obj1, FileEntity * _Nonnull obj2) {
        
        return [obj1.fileNameDeleteExtension compare:obj2.fileNameDeleteExtension]; //升序
    }];
    self.folderArray = result.mutableCopy;
    if (folderEntity_error) {
        [self.folderArray removeObject:folderEntity_error];
        [self.folderArray addObject:folderEntity_error];
    }
    
    
    //    if ([folderEntity.fileName isEqualToString:ErrorFolderName]
    //        ) {
    //        if (folderEntity.itemArray.count == 0) {
    //            // ios 假如Error文件夹为空的话 忽略
    //
    //            [self.folderArray removeObject:folderEntity];
    //            continue;
    //        } else {
    //            folderEntity_error = folderEntity;
    //        }
    //    }
    //
    self.mplShare.allFileEntity = nil;
    self.mplShare.allFileEntity = ({
        FileEntity * fileEntity = [FileEntity new];
        fileEntity.fileName  = @"全部";
        fileEntity.fileID    = KRootCellFolderName_all;
        
        fileEntity.fileType  = FileType_virtualFolder;
        fileEntity.itemArray = [NSMutableArray<FileEntity, Ignore> new];
        
        for (FileEntity * fe in self.folderArray) {
            if (fe == folderEntity_error) {
                continue;
            } else {
                [fileEntity.itemArray addObjectsFromArray:fe.itemArray];
            }
        }
        
        fileEntity;
    });
    
    self.localArray = self.folderArray;
    
    [self freshFavFolderEvent];
}

#pragma mark - VCDataSource
- (void)freshFavFolderEvent {
    self.recordArray = [NSMutableArray<FileEntity> new];
    
    [self.mplShare.allFileEntityDic removeAllObjects];
    for (FileEntity * fe in self.mplShare.allFileEntity.itemArray) {
        self.mplShare.allFileEntityDic[fe.filePath] = fe;
    }
    
    for (FileEntity *fe in self.mplShare.list.songListArray) {
        
        FileEntity * listFE = [FileEntity new];
        listFE.fileName   = fe.fileName;
        listFE.fileID     = fe.fileID;
        listFE.fileType   = FileType_virtualFolder;
        listFE.itemArray  = [NSMutableArray<FileEntity> new];
        [self.recordArray addObject:listFE];
        
        for (FileEntity *fe0 in fe.itemArray) {
            FileEntity *fe1 = self.mplShare.allFileEntityDic[fe0.filePath];
            [listFE.itemArray addObject:fe1];
        }
    }
    // 重置记录list, 使得他们使用同一个地址
    [self.mplShare.list.songListArray removeAllObjects];
    [self.mplShare.list.songListArray addObjectsFromArray:self.recordArray];
    
    [self.recordArray insertObject:self.mplShare.allFileEntity atIndex:0];
}

- (void)addListName:(NSString *)name {
    FileEntity * list = [FileEntity new];
    list.fileName   = name;
    list.fileID     = [NSString getUUID];
    [self.mplShare.list.songListArray addObject:list];
    [self updateSongList];
}

- (void)updateSongList {
    [self.mplShare updateSongList];
}

@end
