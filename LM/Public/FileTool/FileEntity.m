//
//  FileEntity.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import "FileEntity.h"

@implementation FileEntity

- (id)copyWithZone:(NSZone *)zone {
    FileEntity *entity = [[[self class] alloc] init]; // <== 注意这里
    entity.folderPath  = self.folderPath;
    entity.fileName    = self.fileName;
    entity.folder      = self.isFolder;
    entity.itemArray   = [self.itemArray mutableCopy];
    
    return entity;
}

@end
