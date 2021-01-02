//
//  LocalMusicVCInteractor.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import "LocalMusicVCInteractor.h"
#import "FileTool.h"
#import "MusicPlayListTool.h"
#import "LrcPrefix.h"
#import "MusicPlayListTool.h"

@interface LocalMusicVCInteractor ()

@property (nonatomic, strong) NSMutableArray<FileEntity> * folderArray;

@end

@implementation LocalMusicVCInteractor

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)initData {
#if TARGET_OS_MACCATALYST
    self.folderArray = [FileTool getArrayAtPath:MusicFolderName type:FileTypeFolder];
#else
    self.folderArray = [FileTool getArrayAtPath:nil type:FileTypeFolder];
#endif
    
    for (NSInteger i = 0; i<self.folderArray.count;) {
        FileEntity * folderEntity = self.folderArray[i];
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
        
        NSMutableArray<FileEntity, Ignore> * itemArray = [FileTool getArrayAtPath:[NSString stringWithFormat:@"%@/%@", folderEntity.folderName, folderEntity.fileName] type:FileTypeItem];
        
        // 排序
        NSArray *result = [itemArray sortedArrayUsingComparator:^NSComparisonResult(FileEntity * _Nonnull obj1, FileEntity * _Nonnull obj2) {
            return [obj1.fileNameDeleteExtension compare:obj2.fileNameDeleteExtension]; //升序
        }];
        folderEntity.itemArray = result.mutableCopy;
        
        i++;
    }
    
    NSArray *result = [self.folderArray sortedArrayUsingComparator:^NSComparisonResult(FileEntity * _Nonnull obj1, FileEntity * _Nonnull obj2) {
        
        return [obj1.fileNameDeleteExtension compare:obj2.fileNameDeleteExtension]; //升序
    }];
    self.folderArray = result.mutableCopy;
    
    self.infoArray = self.folderArray;
}

#pragma mark - VCDataSource



@end
