//
//  LrcFetch.h
//  LM
//
//  Created by popor on 2020/10/13.
//  Copyright © 2020 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LrcPrefix.h"
#import "LrcListEntity.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^BlockPLrcListEntity) (LrcListEntity * _Nullable listEntity);

@interface LrcFetch : NSObject

+ (void)getLrcList:(NSString *)musicName finish:(BlockPLrcListEntity)finish;

+ (void)getLrcDetail:(NSString *)musicName url:(NSString *)url finish:(BlockPString)finish;

@end

NS_ASSUME_NONNULL_END

/* // 老的歌单数据
 - (void)updateLyric {
 if ([self.lastMusicTitle isEqualToString:self.currentItem.musicName] && self.musicLyricDic) {
 return;
 }
 self.musicLyricDic   = nil;
 self.musicLyricArray = nil;
 self.lastMusicTitle  = self.currentItem.musicName;
 
 //NSString * musicName = @"世界第一等";
 NSString * musicName = self.lastMusicTitle;
 @weakify(self);
 [LrcFetch getLrcList:self.lastMusicTitle finish:^(LrcListEntity * _Nullable listEntity) {
 if (listEntity.result.count > 0) {
 LrcListUnitEntity * ue = listEntity.result.firstObject;
 [LrcFetch getLrcDetail:musicName url:ue.lrc finish:^(NSString *string) {
 @strongify(self);
 NSDictionary * originDic = [LrcTool parselrc:string];
 
 NSMutableArray * originArray = [NSMutableArray new];
 NSArray * timeTextArray = originDic.allKeys;
 for (NSString * timeText in timeTextArray) {
 
 LrcDetailEntity * entity = [LrcDetailEntity new];
 entity.timeText = timeText;
 entity.lrc      = originDic[timeText];;
 
 NSRange range = [timeText rangeOfString:@":"];
 NSInteger mm  = [timeText substringToIndex:range.location].integerValue;
 NSInteger ss  = [timeText substringFromIndex:range.location +1].integerValue;
 entity.time   = mm*60 +ss;
 
 [originArray addObject:entity];
 }
 
 self.musicLyricArray = [originArray sortedArrayUsingComparator:^NSComparisonResult(LrcDetailEntity * obj1, LrcDetailEntity * obj2) {
 //return [obj1.time compare:obj2.time]; //升序
 return obj1.time<obj2.time ? NSOrderedAscending:NSOrderedDescending;
 }];
 
 
 NSMutableDictionary * tempDic = [NSMutableDictionary new];
 NSInteger count = self.musicLyricArray.count;
 for (NSInteger row = 0; row<count; row++) {
 LrcDetailEntity * entity = self.musicLyricArray[row];
 entity.row = row;
 
 tempDic[entity.timeText] = entity;
 }
 self.musicLyricDic = tempDic;
 
 NSDictionary * dic = @{@"lrcArray":self.musicLyricArray};
 [MGJRouter openURL:MUrl_updateLrcData withUserInfo:dic completion:nil];
 
 // for (LrcDetailEntity * entity in self.musicLyricArray) {
 //     [NSAssistant NSLogEntity:entity];
 //     NSLog(@"\n ");
 // }
 }];
 } else {
 [MGJRouter openURL:MUrl_updateLrcData];
 }
 }];
 }
 //*/
