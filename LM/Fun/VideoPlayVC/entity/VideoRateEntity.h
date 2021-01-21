//
//  VideoRateEntity.h
//  hywj
//
//  Created by popor on 2020/6/15.
//  Copyright © 2020 popor. All rights reserved.
//

#import <PoporJsonModel/PoporJsonModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoRateEntity : PoporJsonModel

@property (nonatomic, copy  ) NSString * title;
@property (nonatomic        ) CGFloat    value;

@end

NS_ASSUME_NONNULL_END
