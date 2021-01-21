//
//  UIDevice+pOrientation.h
//  hywj
//
//  Created by popor on 2020/12/31.
//  Copyright © 2020 popor. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (pOrientation)

+ (void)updateOrientation:(UIDeviceOrientation)orientation;

@end

NS_ASSUME_NONNULL_END
