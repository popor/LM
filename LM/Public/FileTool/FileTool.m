//
//  FileTool.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import "FileTool.h"

@implementation FileTool

+ (NSMutableArray *)getArrayAtPath:(NSString * _Nullable)path type:(FileType)type {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //下面是指定沙盒的路径。我要读取pc上的，所以就用自己pc上的路径
    NSString * folderName;
    NSString * docPath;
    {
        NSArray * pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docPath = pathArray[0]; //获得Document系统文件目录路径
    }
    if (!path) {
        path       = docPath;
        folderName = @"";
    }else{
        folderName = [path lastPathComponent];
        path       = [NSString stringWithFormat:@"%@/%@", docPath, path];
    }
    //NSLog(@"filePath: %@", path);
    
    NSMutableArray * files = [[NSMutableArray alloc] init];
    
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
        entity.folderName = folderName;
        entity.fileName   = fileName;
        if(folderFlag){
            [direnum skipDescendants];
            entity.folder = YES;
        }else{
            entity.folder = NO;
        }
        switch (type) {
            case FileTypeFolder:{
                if (entity.isFolder) {
                    [files addObject:entity];
                }
                break;
            }
            case FileTypeItem:{
                if (!entity.isFolder) {
                    [files addObject:entity];
                }
                break;
            }
            case FileTypeAll:{
                [files addObject:entity];
                break;
            }
            default:{
                [files addObject:entity];
                break;
            }
        }
    }
    if (type == FileTypeAll) {
        [files sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
            FileEntity * entity1 = (FileEntity *)obj1;
            FileEntity * entity2 = (FileEntity *)obj2;
            if (entity1.isFolder != entity2.isFolder) {
                return entity1.isFolder ? NSOrderedAscending:NSOrderedDescending;
            }else{
                return [entity1.fileName floatValue] < [entity2.fileName floatValue] ? NSOrderedAscending:NSOrderedDescending;
            }
        }];
    }
    
    return files;
}

@end
