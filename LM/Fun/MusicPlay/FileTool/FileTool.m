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

//+ (NSString *)getAppDocPath {
//#if !TARGET_OS_MACCATALYST
//    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//#else
//    return [self getFileToolDoc];
//#endif
//}
//
//+ (void)saveFileToolDoc:(NSString *)fileToolDoc {
//    [[NSUserDefaults standardUserDefaults] setObject:fileToolDoc forKey:@"fileToolDoc"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//+ (NSString *)getFileToolDoc {
//    NSString * info = [[NSUserDefaults standardUserDefaults] objectForKey:@"fileToolDoc"];
//    if (!info) {
//        info = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//        [self saveFileToolDoc:info];
//    }
//    return info;
//}


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
    
    NSMutableArray * files = [NSMutableArray<FileEntity> new];
    
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
        entity.filePath   = [NSString stringWithFormat:@"%@/%@", folderName, fileName];
        if(folderFlag){
            [direnum skipDescendants];
            entity.folder = YES;
        }else{
            entity.folder = NO;
            if (fileName.pathExtension.length > 0) {
                entity.fileNameDeleteExtension = [fileName substringToIndex:fileName.length - fileName.pathExtension.length - 1];
            } else {
                entity.fileNameDeleteExtension = fileName;
            }
            
            NSRange range = [entity.fileNameDeleteExtension rangeOfString:@"-"];
            if (range.location > 0 && range.length > 0) {
                entity.musicName  = [entity.fileNameDeleteExtension substringFromIndex:range.location + range.length];
                entity.musicAuthor = [entity.fileNameDeleteExtension substringToIndex:range.location];
                
                entity.musicName  = [entity.musicName replaceWithREG:@"^\\s+" newString:@""];
                entity.musicAuthor = [entity.musicAuthor replaceWithREG:@"\\s+$" newString:@""];
            }else{
                entity.musicName  = entity.fileNameDeleteExtension;
                entity.musicAuthor = @"";
            }
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
