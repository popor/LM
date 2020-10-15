//
//  LrcTool.m
//  LM
//
//  Created by popor on 2020/10/15.
//  Copyright © 2020 popor. All rights reserved.
//

#import "LrcTool.h"

@implementation LrcTool

+ (void)load {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", FT_docPath, LrcFolderName]
                                  withIntermediateDirectories:YES attributes:nil error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", FT_docPath, LrcListFolderName]
                                  withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSLog(@"path: %@", FT_docPath);
    });
}

+ (NSString *)lycListPath:(NSString *)musicName {
    return [NSString stringWithFormat:@"%@/%@/%@.%@", FT_docPath, LrcListFolderName, musicName, @"json"];
}

+ (NSString *)lycPath:(NSString *)musicName {
    return [NSString stringWithFormat:@"%@/%@/%@.%@", FT_docPath, LrcFolderName, musicName, @"lrc"];
}

// https://www.yuanmas.com/info/mZzgxv2oaK.html
+ (NSMutableDictionary*)parselrc:(NSString*)content {
    // 初始化一个字典
    NSMutableDictionary *musicLrcDictionary = [NSMutableDictionary new];
    NSArray *strlineArray = [content componentsSeparatedByString:@"\n"];
    
    // 安行读取歌词歌词
    for (int i=0; i<[strlineArray count]; i++) {
        
        // 将时间和歌词分割
        NSArray *lineComponents = [strlineArray[i] componentsSeparatedByString:@"]"];
        
        NSString * word = lineComponents.lastObject;
        word = [word stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (word.length == 0) {
            //NSLog(@"忽略: %@", strlineArray[i]);
            continue;
        }
        
        for (NSInteger timeIndex = 0; timeIndex < [lineComponents count] -1; timeIndex++) {
            NSString *strKuTimer = lineComponents[timeIndex];
            
            if ([strKuTimer length] >1) {
                NSString * timerText = [strKuTimer substringFromIndex:1];
                if ([timerText containsString:@"."]) {
                    NSRange range = [timerText rangeOfString:@"."];
                    timerText = [timerText substringToIndex:range.location];
                }
                musicLrcDictionary[timerText] = word;
                //NSLog(@"%@ _ %@", timerText, word);
            }
        }
    }
    
    //    在这里返回整个字典
    return musicLrcDictionary;
}

@end
