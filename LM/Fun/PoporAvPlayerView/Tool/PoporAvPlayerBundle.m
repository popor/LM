//
//  PoporAvPlayerBundle.m
//  hywj
//
//  Created by popor on 2020/9/5.
//  Copyright © 2020 popor. All rights reserved.
//

#import "PoporAvPlayerBundle.h"

@implementation PoporAvPlayerBundle

+ (UIImage *)imageBundleNamed:(NSString *)imageName {
    UIImage * (^ imageBundleBlock)(NSString *) = ^(NSString *imageName){
        static NSBundle * bundle;
        if (!bundle) {
            bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"PoporAvPlayer" ofType:@"bundle"]];
        }
        return [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    };
    return imageBundleBlock(imageName);
}

@end
