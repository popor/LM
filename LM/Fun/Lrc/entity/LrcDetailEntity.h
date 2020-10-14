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

@property (nonatomic        ) CGFloat time;
@property (nonatomic, copy  ) NSString * timeText;
@property (nonatomic, copy  ) NSString * lrc;

@end

NS_ASSUME_NONNULL_END
