//
//  LrcTool.h
//  LM
//
//  Created by popor on 2020/10/15.
//  Copyright © 2020 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LrcPrefix.h"

NS_ASSUME_NONNULL_BEGIN

@interface LrcTool : NSObject

+ (NSString *)lycListPath:(NSString *)musicName;
+ (NSString *)lycPath:(NSString *)musicName;

+ (NSMutableDictionary*)parselrc:(NSString*)content;

@end

NS_ASSUME_NONNULL_END
