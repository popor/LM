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
+ (NSMutableDictionary*)parselrc_1vsN:(NSString*)content {
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


+ (void)parselrc_1vs1:(NSString*)content finish:(void (^ __nullable)(NSMutableDictionary * musicDic, NSMutableArray<LrcDetailEntity *> * musicArray))block {
    // 初始化一个字典
    NSMutableDictionary * musicLrcDictionary = [NSMutableDictionary new];
    NSMutableArray<LrcDetailEntity *> * musicArray = [NSMutableArray<LrcDetailEntity *> new];
    
    NSArray *strlineArray = [content componentsSeparatedByString:@"\n"];
    
    // 安行读取歌词歌词
    for (NSInteger lrcIndex=0, row = 0; lrcIndex<[strlineArray count]; lrcIndex++) {
        // 将时间和歌词分割
        NSArray *lineComponents = [strlineArray[lrcIndex] componentsSeparatedByString:@"]"];
        
        if (lineComponents.count == 2) {
            NSString * word = lineComponents.lastObject;
            word = [word stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString * timerText;
            
            if (word.length == 0) {
                timerText = [NSString stringWithFormat:@"00:00.%02i", (int)row*30];
                
                word = lineComponents.firstObject;
                
                if ([word hasPrefix:@"[ar"]) {
                    word = [word substringFromIndex:4];
                } else if ([word hasPrefix:@"[ti"]) {
                    word = [word substringFromIndex:4];
                }
                else {
                    continue;
                }
                
            } else { // 正常歌词
                timerText = lineComponents.firstObject;
                timerText = [timerText substringFromIndex:1];
                if (timerText.length == 5) {
                    timerText = [NSString stringWithFormat:@"%@.00", timerText];
                }
            }
            
            LrcDetailEntity * entity = [LrcDetailEntity new];

            entity.time = [self timeFromText:timerText];
            
            // !!!: 为了节省资源 将8位的末尾号变为0
            if (LrcMonitor0_1S) {
                entity.timeText8 = [NSString stringWithFormat:@"%@0", [timerText substringToIndex:7]];
            } else {
                entity.timeText8 = timerText;
            }
            entity.timeText5 = [timerText substringToIndex:5];
            entity.lrcText   = word;
            entity.row       = row++;
            
            musicLrcDictionary[entity.timeText8] = entity;
            [musicArray addObject:entity];
        } else {
            // 不处理
            
        }
    }
    
    if (block) {
        block(musicLrcDictionary, musicArray);
    }
}


+ (NSInteger)timeFromText:(NSString *)timeText {
    NSRange range = [timeText rangeOfString:@":"];
    NSInteger mm  = [timeText substringToIndex:range.location].integerValue;
    NSInteger ss  = [timeText substringFromIndex:range.location +1].integerValue;
    NSInteger time = mm*60 +ss;
    return time;
}

@end
