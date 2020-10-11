//
//  ThemeColor.m
//  LM
//
//  Created by popor on 2020/9/20.
//  Copyright © 2020 popor. All rights reserved.
//

#import "ThemeColor.h"

@implementation ThemeColor

+ (instancetype)share {
    static dispatch_once_t once;
    static ThemeColor * instance;
    dispatch_once(&once, ^{
        instance = [ThemeColor new];
        //        if (@available(iOS 13, *)) {
        //            instance.userInterfaceStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
        //        }
        
        [instance initData];
    });
    return instance;
}

- (void)initData {
    
    self.themeColor = [UIColor colorWithRed:0.2 green:0.752941 blue:0.745098 alpha:1];
    
    if (@available(iOS 13, *)) {
        self.bgColor1       = [UIColor systemGroupedBackgroundColor];
        self.bgColor2       = [UIColor secondarySystemGroupedBackgroundColor];
        self.bgColor3       = [UIColor tertiarySystemGroupedBackgroundColor];
        
        self.separatorColor = [UIColor separatorColor];
        
        self.labelColor     = [UIColor labelColor];
        
        self.textNColor     = [UIColor labelColor];
        self.textNColor2    = [UIColor secondaryLabelColor];
        
    } else {
        self.bgColor1       = [UIColor whiteColor];
        self.bgColor2       = [UIColor whiteColor];
        self.bgColor3       = [UIColor whiteColor];
        
        self.separatorColor = nil;
        
        self.labelColor     = [UIColor blackColor];
        
        self.textNColor     = [UIColor blackColor];
        self.textNColor2    = [UIColor grayColor];
    }
    
    self.textSColor     = self.themeColor;
    
}

@end
