//
//  PoporAvPlayerBundle.h
//  hywj
//
//  Created by popor on 2020/9/5.
//  Copyright © 2020 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define PoporAvPlayerImage(imageName) [PoporAvPlayerBundle imageBundleNamed:imageName]

@interface PoporAvPlayerBundle : NSObject

+ (UIImage *)imageBundleNamed:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
