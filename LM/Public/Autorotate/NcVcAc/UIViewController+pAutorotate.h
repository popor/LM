//
//  UIViewController+pAutorotate.h
//  hywj
//
//  Created by popor on 2020/6/12.
//  Copyright © 2020 popor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAutorotate.h"

NS_ASSUME_NONNULL_BEGIN

#define PScreenWidth  [UIViewController portainWidth]
#define PScreenHeight [UIViewController portainHeight]

@interface UIViewController (pAutorotate)

+ (CGFloat)portainWidth;
+ (CGFloat)portainHeight;

@end

NS_ASSUME_NONNULL_END
