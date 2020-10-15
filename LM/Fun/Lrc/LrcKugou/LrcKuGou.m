//
//  LrcKuGou.m
//  LM
//
//  Created by popor on 2020/10/15.
//  Copyright © 2020 popor. All rights reserved.
//

#import "LrcKuGou.h"
#import "NetService.h"

#import "MusicPlayListTool.h"
#import "LrcKugouListEntity.h"
#import "LrcKugouDetailEntity.h"
#import <Base64/MF_Base64Additions.h>

@implementation LrcKuGou

+ (void)test:(FileEntity *)item {
    
//    NSString * url;
//    // url = [NSString stringWithFormat:@"http://lyrics.kugou.com/search?ver=1&man=yes&client=pc&keyword=%@&duration=%i", [item.fileName stringByDeletingLastPathComponent], (int)0];
//    // http://lyrics.kugou.com/search?ver=1&man=yes&client=pc&keyword=%E5%88%98%E7%8F%82%E7%9F%A3%20-%20%E5%A2%A8%E7%97%95&duration=239000
//    //url = [NSString stringWithFormat:@"http://lyrics.kugou.com/search?ver=1&man=yes&client=pc&keyword=%@&duration=%i", @"刘珂矣 - 墨痕", (int)239000];
//    // url = [NSString stringWithFormat:@"http://lyrics.kugou.com/search?ver=1&man=yes&client=pc&keyword=%@&duration=%i", @"Mariah Carey - Without You", (int)215000];
//    url = [NSString stringWithFormat:@"http://lyrics.kugou.com/search?ver=1&man=yes&client=pc&keyword=%@&duration=%i", item.fileName, (int)item.musicDuration*1000];
//    
//    NSLog(@"url: %@", url);
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
//        
////        if (dic) {
////            LrcListEntity * entity = [[LrcListEntity alloc] initWithDictionary:dic error:nil];
////            [data writeToFile:savePath atomically:YES];
////            if (entity.result.count > 0) {
////                finish(entity);
////            } else {
////                finish(nil);
////            }
////        }else{
////            finish(nil);
////        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
////        finish(nil);
//    }];
}


+ (void)testLrcDetailUrl:(NSString *)url {
    
    NSLog(@"url: %@", url);
    [NetService title:nil url:url method:PoporMethodGet parameters:nil success:^(NSString * _Nonnull url, NSData * _Nullable data, NSDictionary * _Nullable dic) {
        NSString * str   = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"酷狗歌词: %@", str);
        LrcKugouDetailEntity * le = [[LrcKugouDetailEntity alloc] initWithDictionary:dic error:nil];
        if (le.content.length > 0) {
            //NSString * t = [AESCrypt AESCrypt:le.content password:nil];
            //NSString * t = [le.content base64String];
            NSString * t = [le.content base64UrlEncodedString];
            NSLog(@"%@", t);
        }
        
        //        if (dic) {
        //            LrcListEntity * entity = [[LrcListEntity alloc] initWithDictionary:dic error:nil];
        //            [data writeToFile:savePath atomically:YES];
        //            if (entity.result.count > 0) {
        //                finish(entity);
        //            } else {
        //                finish(nil);
        //            }
        //        }else{
        //            finish(nil);
        //        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //        finish(nil);
    }];
}



@end
