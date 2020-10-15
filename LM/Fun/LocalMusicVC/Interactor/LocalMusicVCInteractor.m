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
            || [folderEntity.fileName isEqualToString:ConfigFolderName]) {
            // ios 忽略3个文件夹
            [self.folderArray removeObject:folderEntity];
            continue;
        }
#endif
        folderEntity.itemArray = [FileTool getArrayAtPath:[NSString stringWithFormat:@"%@/%@", folderEntity.folderName, folderEntity.fileName] type:FileTypeItem];
        i++;
    }
    self.infoArray = self.folderArray;
}

#pragma mark - VCDataSource



@end
