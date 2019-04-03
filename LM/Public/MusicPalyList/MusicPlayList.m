//
//  MusicPlayList.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import "MusicPlayList.h"

@implementation MusicPlayItemEntity

+ (MusicPlayItemEntity *)initWithFileEntity:(FileEntity *)fileEntity {
    MusicPlayItemEntity * itme = [MusicPlayItemEntity new];
    itme.docPath     = [NSString stringWithFormat:@"%@/%@", fileEntity.folderName, fileEntity.fileName];
    itme.fileName    = fileEntity.fileName;
    itme.musicTitle  = fileEntity.musicTitle;
    itme.musicAuthor = fileEntity.musicAuthor;
    
    
    
    return itme;
}

@end

@implementation MusicPlayListEntity

- (id)init {
    if (self = [super init]) {
        _array = [NSMutableArray new];
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"array" : [MusicPlayItemEntity class]};
}

@end

@implementation MusicPlayList

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"array" : [MusicPlayListEntity class]};
}

@end
