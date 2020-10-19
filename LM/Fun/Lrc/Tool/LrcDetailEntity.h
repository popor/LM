//
//  LrcDetailEntity.h
//  LM
//
//  Created by popor on 2020/10/14.
//  Copyright © 2020 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LrcDetailEntity : NSObject

@property (nonatomic        ) NSInteger row;
@property (nonatomic        ) CGFloat time;
@property (nonatomic, copy  ) NSString * timeText8; // 01:01.01
@property (nonatomic, copy  ) NSString * timeText5; // 01:01

@property (nonatomic, copy  ) NSString * lrcText;

@end

NS_ASSUME_NONNULL_END
