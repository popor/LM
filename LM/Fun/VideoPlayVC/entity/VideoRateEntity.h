//
//  VideoRateEntity.h
//  hywj
//
//  Created by popor on 2020/6/15.
//  Copyright © 2020 popor. All rights reserved.
//

#import <PoporJsonModel/PoporJsonModel.h>

NS_ASSUME_NONNULL_BEGIN

#define VRE_TV(title, value) [[VideoRateEntity alloc] initTitle:title v##alue:value]

@interface VideoRateEntity : PoporJsonModel

@property (nonatomic, copy  ) NSString * title;
@property (nonatomic        ) CGFloat    value;

- (instancetype)initTitle:(NSString *)title value:(CGFloat)value;

@end

NS_ASSUME_NONNULL_END
