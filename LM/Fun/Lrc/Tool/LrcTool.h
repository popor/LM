//
//  LrcTool.h
//  LM
//
//  Created by popor on 2020/10/15.
//  Copyright © 2020 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LrcPrefix.h"
#import "LrcDetailEntity.h"

NS_ASSUME_NONNULL_BEGIN

static BOOL LrcMonitor0_1S = YES; // 是否使用0.1秒的间隔还是0.01秒间隔

@interface LrcTool : NSObject

+ (NSString *)lycListPath:(NSString *)musicName;
+ (NSString *)lycPath:(NSString *)musicName;

+ (NSMutableDictionary*)parselrc_1vsN:(NSString*)content;

+ (void)parselrc_1vs1:(NSString*)content finish:(void (^ __nullable)(NSMutableDictionary * musicDic, NSMutableArray<LrcDetailEntity *> * musicArray))block;

+ (NSInteger)timeFromText:(NSString *)timeText;

@end

NS_ASSUME_NONNULL_END
