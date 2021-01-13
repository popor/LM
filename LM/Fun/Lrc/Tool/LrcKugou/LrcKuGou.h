//
//  LrcKuGou.h
//  LM
//
//  Created by popor on 2020/10/15.
//  Copyright © 2020 popor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicPlayListEntity.h"
#import "LrcKugouListEntity.h"
#import "LrcKugouDetailEntity.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^BlockPLrcKugouListEntity) (LrcKugouListEntity * _Nullable listEntity);

@interface LrcKuGou : NSObject


+ (void)getLrcList:(FileEntity *)item finish:(BlockPLrcKugouListEntity)finish;

+ (void)getLrcDetail:(FileEntity *)item id:(NSString *)kugouId accesskey:(NSString *)kugouAccesskey finish:(BlockPString)finish;

//+ (void)test:(FileEntity *)item;

@end

NS_ASSUME_NONNULL_END
