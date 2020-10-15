//
//  LrcKuGou.m
//  LM
//
//  Created by popor on 2020/10/15.
//  Copyright © 2020 popor. All rights reserved.
//

#import "LrcKuGou.h"
#import "NetService.h"
#import "LrcTool.h"
#import "MusicPlayListTool.h"
#import "LrcKugouListEntity.h"
#import "LrcKugouDetailEntity.h"
#import <Base64/MF_Base64Additions.h>
#import <PoporFoundation/NSString+pTool.h>

@implementation LrcKuGou

+ (void)getLrcList:(FileEntity *)item finish:(BlockPLrcKugouListEntity)finish {
    if (!finish) {
        return;
    }
    NSString * savePath = [LrcTool lycListPath:item.fileNameDeleteExtension];
    
    {
        NSData * data = [NSData dataWithContentsOfFile:savePath];
        LrcKugouListEntity * entity = [[LrcKugouListEntity alloc] initWithData:data error:nil];
        
        if (data) {
            finish(entity);
            return;
        }
    }
    
    NSString * url = [NSString stringWithFormat:@"http://lyrics.kugou.com/search?ver=1&man=yes&client=pc&keyword=%@&duration=%i", item.fileNameDeleteExtension, (int)item.musicDuration*1000];
    
    [NetService title:nil url:url method:PoporMethodGet parameters:nil success:^(NSString * _Nonnull url, NSData * _Nullable data, NSDictionary * _Nullable dic) {
        if (dic) {
            LrcKugouListEntity * entity = [[LrcKugouListEntity alloc] initWithDictionary:dic error:nil];
            [data writeToFile:savePath atomically:YES];
            if (entity.lrcArray.count > 0) {
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

+ (void)getLrcDetail:(FileEntity *)item id:(NSString *)kugouId accesskey:(NSString *)kugouAccesskey finish:(BlockPString)finish {
    if (!finish) {
        return;
    }
    NSString * savePath = [LrcTool lycPath:item.fileNameDeleteExtension];
    
    {
        NSData   * data = [NSData dataWithContentsOfFile:savePath];
        NSString * str  = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (str.length > 0) {
            finish(str);
            return;
        }
    }
    NSString * url = [NSString stringWithFormat:@"http://lyrics.kugou.com/download?ver=1&client=pc&id=%@&accesskey=%@&fmt=lrc&charset=utf8", kugouId, kugouAccesskey];
    
    [NetService title:nil url:url method:PoporMethodGet parameters:nil success:^(NSString * _Nonnull url, NSData * _Nullable data, NSDictionary * _Nullable dic) {
        LrcKugouDetailEntity * le = [[LrcKugouDetailEntity alloc] initWithDictionary:dic error:nil];
        if (le.content.length > 100) {
            NSData  * originData = [MF_Base64Codec dataFromBase64String:le.content];
            NSString * str       = [[NSString alloc] initWithData:originData encoding:NSUTF8StringEncoding];
            //NSLog(@"%@", str);
            [originData writeToFile:savePath atomically:YES];
            
            finish(str);
        } else {
            finish(nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        finish(nil);
    }];
}
//
//+ (void)test:(FileEntity *)item {
//    NSString * fileName = [item.fileName replaceWithREG:@"\\..{3,4}$" newString:@""];
//    NSString * url = [NSString stringWithFormat:@"http://lyrics.kugou.com/search?ver=1&man=yes&client=pc&keyword=%@&duration=%i", fileName, (int)item.musicDuration*1000];
//    
//    NSLog(@"lrc列表: %@", url);
//    [NetService title:nil url:url method:PoporMethodGet parameters:nil success:^(NSString * _Nonnull url, NSData * _Nullable data, NSDictionary * _Nullable dic) {
//        NSString * str   = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"酷狗歌词: %@", str);
//        LrcKugouListEntity * le = [[LrcKugouListEntity alloc] initWithDictionary:dic error:nil];
//        if (le.lrcArray.count > 0) {
//            LrcKugouListUnitEntity * ue = le.lrcArray.firstObject;
//            
//            //[self testLrcDetailUrl:[NSString stringWithFormat:@"http://lyrics.kugou.com/download?ver=1&client=pc&id=%@&accesskey=%@&fmt=krc&charset=utf8", ue.id, ue.accesskey]];
//            // lrc可以使用base64解析出来.
//            [self testLrcDetailUrl:[NSString stringWithFormat:@"http://lyrics.kugou.com/download?ver=1&client=pc&id=%@&accesskey=%@&fmt=lrc&charset=utf8", ue.id, ue.accesskey]];
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
////        finish(nil);
//    }];
//}
//
//
//+ (void)testLrcDetailUrl:(NSString *)url {
//    
//    NSLog(@"url: %@", url);
//    [NetService title:nil url:url method:PoporMethodGet parameters:nil success:^(NSString * _Nonnull url, NSData * _Nullable data, NSDictionary * _Nullable dic) {
//        NSString * str   = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"酷狗歌词: %@", str);
//        LrcKugouDetailEntity * le = [[LrcKugouDetailEntity alloc] initWithDictionary:dic error:nil];
//        if (le.content.length > 0) {
//            //NSString * t = [AESCrypt AESCrypt:le.content password:nil];
//            //NSString * t = [le.content base64String];
//            //NSString * t = [le.content base64UrlEncodedString];
//            NSData * data = [MF_Base64Codec dataFromBase64String:le.content];
//            NSString * str   = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"%@", str);
//        }
//        
//        //        if (dic) {
//        //            LrcListEntity * entity = [[LrcListEntity alloc] initWithDictionary:dic error:nil];
//        //            [data writeToFile:savePath atomically:YES];
//        //            if (entity.result.count > 0) {
//        //                finish(entity);
//        //            } else {
//        //                finish(nil);
//        //            }
//        //        }else{
//        //            finish(nil);
//        //        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        //        finish(nil);
//    }];
//}



@end
