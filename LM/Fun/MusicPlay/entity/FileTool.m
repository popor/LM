//
//  FileTool.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import "FileTool.h"

@implementation FileTool

+ (NSString *)getAppDocPath {
    static NSString * path;
    if (!path) {
        path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    }
    return path;
}

+ (NSMutableArray<FileEntity> *)getArrayAtPath:(NSString * _Nullable)path type:(FileType)type {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //下面是指定沙盒的路径。我要读取pc上的，所以就用自己pc上的路径
    NSString * folderName;
    NSString * docPath = FT_docPath;
    if (!path) {
        path       = docPath;
        folderName = @"";
    }else{
        folderName = [path lastPathComponent];
        path       = [NSString stringWithFormat:@"%@/%@", docPath, path];
    }
    //NSLog(@"filePath: %@", path);
    
    NSMutableArray<FileEntity> * fileArray = [NSMutableArray<FileEntity> new];
    
    NSDirectoryEnumerator *direnum = [fileManager enumeratorAtPath:path]; //遍历目录
    NSString *fileName;
    
    while((fileName = [direnum nextObject]) != nil){
        if ([fileName hasSuffix:WFIgnoreFile]) {
            continue;
        }
        //NSLog(@"name : %@", fileName);
        BOOL folderFlag;
        [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", path, fileName] isDirectory:&folderFlag];
        FileEntity * entity = [FileEntity new];
        
        if (folderFlag) {
            [direnum skipDescendants];
            [entity updateFileFolder:folderName fileType:FileType_folder FileName:fileName];
        } else {
            [entity updateFileFolder:folderName fileType:FileType_file FileName:fileName];
        }
        
        switch (type) {
            case FileType_folder:{
                if (entity.isFolder) {
                    [fileArray addObject:entity];
                }
                break;
            }
            case FileType_file:{
                if (!entity.isFolder) {
                    [fileArray addObject:entity];
                }
                break;
            }
            default:{
                //[fileArray addObject:entity];
                break;
            }
        }
    }
    
    [fileArray sortUsingComparator:^NSComparisonResult(FileEntity * entity1, FileEntity * entity2) {
        if (entity1.isFolder != entity2.isFolder) {
            return entity1.isFolder ? NSOrderedAscending:NSOrderedDescending;
        }else{
            return [entity1.fileName compare:entity2.fileName] ? NSOrderedAscending:NSOrderedDescending;
        }
    }];
    
    return fileArray;
}

@end
