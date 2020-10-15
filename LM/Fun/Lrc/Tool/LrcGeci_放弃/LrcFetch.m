//
//  LrcFetch.m
//  LM
//
//  Created by popor on 2020/10/13.
//  Copyright © 2020 popor. All rights reserved.
//

#import "LrcFetch.h"
#import "NetService.h"
#import "LrcTool.h"

@implementation LrcFetch

+ (void)getLrcList:(NSString *)musicName finish:(BlockPLrcListEntity)finish {
    if (!finish) {
        return;
    }
    NSString * savePath = [LrcTool lycListPath:musicName];
    
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
    NSString * savePath = [LrcTool lycPath:musicName];
    
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

@end
