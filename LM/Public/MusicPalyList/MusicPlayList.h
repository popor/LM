//
//  MusicPlayList.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FileEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface MusicPlayItemEntity : NSObject

@property (nonatomic, strong) NSString * filePath;
@property (nonatomic, strong) NSString * fileName;

@property (nonatomic, strong) NSString * musicTitle;
@property (nonatomic, strong) NSString * musicAuthor;

@property (nonatomic, strong) UIImage  * musicCover;

//@property (nonatomic        ) int      duration;
//@property (nonatomic        ) int index;

@property (nonatomic, getter=isAvailable) BOOL available; // 是否还存在

+ (MusicPlayItemEntity *)initWithFileEntity:(FileEntity *)fileEntity;

- (UIImage *)coverImage;

@end


@interface MusicPlayListEntity : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSMutableArray<MusicPlayItemEntity *> * array;

@end


@interface MusicPlayList : NSObject

@property (nonatomic, strong) NSMutableArray<MusicPlayListEntity *> * array;

@end

NS_ASSUME_NONNULL_END
