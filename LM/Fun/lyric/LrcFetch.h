//
//  LrcFetch.h
//  LM
//
//  Created by popor on 2020/10/13.
//  Copyright © 2020 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LrcListEntity.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * LrcFolderName = @"lrc";
static NSString * LrcListFolderName = @"lrcList";

typedef void(^BlockPLrcListEntity) (LrcListEntity * _Nullable listEntity);

@interface LrcFetch : NSObject

+ (void)getLrcList:(NSString *)musicName finish:(BlockPLrcListEntity)finish;

+ (void)getLrcDetail:(NSString *)musicName url:(NSString *)url finish:(BlockPString)finish;

+ (NSMutableDictionary*)parselrc:(NSString*)content;

@end

NS_ASSUME_NONNULL_END
