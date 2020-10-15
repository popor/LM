//
//  FileTool.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FileEntity.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(int, FileType) {
    FileTypeFolder,
    FileTypeItem,
    FileTypeAll,
};

#define FT_docPath [FileTool getAppDocPath]

@interface FileTool : NSObject

+ (NSString *)getAppDocPath;

+ (NSMutableArray<FileEntity> *)getArrayAtPath:(NSString *_Nullable)path type:(FileType)type;

@end

NS_ASSUME_NONNULL_END
