//
//  FileEntity.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * WFIgnoreFile = @".DS_Store";

@interface FileEntity : NSObject

@property (nonatomic, strong) NSString *folderName;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) NSString * musicAuthor;
@property (nonatomic, strong) NSString * musicTitle;
//@property (nonatomic, strong) UIImage  * musicCover;

@property (nonatomic, getter=isFolder) BOOL folder;

@property (nonatomic, strong) NSMutableArray * itemArray;

@end

NS_ASSUME_NONNULL_END
