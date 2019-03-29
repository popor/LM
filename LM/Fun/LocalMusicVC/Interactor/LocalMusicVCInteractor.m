//
//  LocalMusicVCInteractor.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import "LocalMusicVCInteractor.h"
#import "FileTool.h"

@interface LocalMusicVCInteractor ()

@property (nonatomic, strong) NSMutableArray * folderArray;

@end

@implementation LocalMusicVCInteractor

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)initData {
    self.folderArray = [FileTool getArrayAtPath:nil type:FileTypeFolder];
    for (FileEntity * folderEntity in self.folderArray) {
        folderEntity.itemArray = [FileTool getArrayAtPath:[NSString stringWithFormat:@"%@/%@", folderEntity.folderPath, folderEntity.fileName] type:FileTypeItem];
    }
    self.infoArray = self.folderArray;
}

#pragma mark - VCDataSource



@end
