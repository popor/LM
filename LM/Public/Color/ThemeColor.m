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
        instance.userInterfaceStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
        
        [instance initData];
    });
    return instance;
}

- (void)initData {
    
    self.themeColor = [UIColor colorWithRed:0.2 green:0.752941 blue:0.745098 alpha:1];
    
    //    if (@available(iOS 13, *)) {
    //        self.bgColor    = self.userInterfaceStyle == UIUserInterfaceStyleLight ?  [UIColor lightGrayColor] : [UIColor darkGrayColor];
    //        self.textNColor = self.userInterfaceStyle == UIUserInterfaceStyleLight ?  [UIColor darkTextColor] : [UIColor lightTextColor];
    //        self.textSColor = self.themeColor;
    //    } else {
    //        self.bgColor    = [UIColor lightGrayColor];
    //        self.textNColor = [UIColor darkTextColor];
    //        self.textSColor = self.themeColor;
    //    }
    
    self.bgColor1       = [UIColor systemGroupedBackgroundColor];
    self.bgColor2       = [UIColor secondarySystemGroupedBackgroundColor];
    self.bgColor3       = [UIColor tertiarySystemGroupedBackgroundColor];

    self.separatorColor = [UIColor separatorColor];

    self.labelColor     = [UIColor labelColor];

    self.textNColor     = [UIColor labelColor];
    self.textSColor     = self.themeColor;
    
}

@end
