//
//  LrcFetch.m
//  LM
//
//  Created by popor on 2020/10/13.
//  Copyright © 2020 popor. All rights reserved.
//

#import "LrcFetch.h"
#import "NetService.h"

@implementation LrcFetch

+ (void)load {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", FT_docPath, LrcFolderName]
                                  withIntermediateDirectories:YES attributes:nil error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", FT_docPath, LrcListFolderName]
                                  withIntermediateDirectories:YES attributes:nil error:nil];
        
    });
}

+ (void)getLrcList:(NSString *)musicName finish:(BlockPLrcListEntity)finish {
    if (!finish) {
        return;
    }
    NSString * savePath = [LrcFetch lycListPath:musicName];
    
    {
        NSData * data = [NSData dataWithContentsOfFile:savePath];
        LrcListEntity * entity = [[LrcListEntity alloc] initWithData:data error:nil];
        
        if (data) {
            finish(entity);
            return;
        }
    }
    
    NSString * url = [NSString stringWithFormat:@"%@/%@", @"http://gecimi.com/api/lyric", musicName];
    
    [NetService title:nil url:url method:PoporMethodGet parameters:nil success:^(NSString * _Nonnull url, NSData * _Nullable data, NSDictionary * _Nullable dic) {
        if (dic) {
            LrcListEntity * entity = [[LrcListEntity alloc] initWithDictionary:dic error:nil];
            [data writeToFile:savePath atomically:YES];
            if (entity.result.count > 0) {
                finish(entity);
            } else {
                finish(nil);
            }
        }else{
            finish(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        finish(nil);
    }];
}

+ (void)getLrcDetail:(NSString *)musicName url:(NSString *)url finish:(BlockPString)finish {
    if (!finish) {
        return;
    }
    NSString * savePath = [LrcFetch lycPath:musicName];
    
    {
        NSData   * data = [NSData dataWithContentsOfFile:savePath];
        NSString * str  = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (str.length > 0) {
            finish(str);
            return;
        }
    }
    
    [NetService title:nil url:url method:PoporMethodGet parameters:nil success:^(NSString * _Nonnull url, NSData * _Nullable data, NSDictionary * _Nullable dic) {
        [data writeToFile:savePath atomically:YES];
        NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        finish(str);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        finish(nil);
    }];
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
                NSLog(@"%@ _ %@", timerText, word);
            }
        }
    }
    
    //    在这里返回整个字典
    return musicLrcDictionary;
}

+ (NSString *)lycListPath:(NSString *)musicName {
    return [NSString stringWithFormat:@"%@/%@/%@.%@", FT_docPath, LrcListFolderName, musicName, @"json"];
}

+ (NSString *)lycPath:(NSString *)musicName {
    return [NSString stringWithFormat:@"%@/%@/%@.%@", FT_docPath, LrcFolderName, musicName, @"text"];
}

@end
