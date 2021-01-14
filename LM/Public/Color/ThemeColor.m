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
        if (@available(iOS 13, *)) {
            instance.previousUserInterfaceStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
        }
        
        [instance initData];
    });
    return instance;
}

- (void)initData {
    
    self.themeColor = PRGBF(96,187,245, 1);
    
    if (@available(iOS 13, *)) {
        self.bgColor1       = [UIColor systemGroupedBackgroundColor];
        self.bgColor2       = [UIColor secondarySystemGroupedBackgroundColor];
        self.bgColor3       = [UIColor tertiarySystemGroupedBackgroundColor];
        
        self.bgColor4       = [UIColor systemBackgroundColor];
        
        self.separatorColor = [UIColor separatorColor];
        
        self.labelColor     = [UIColor labelColor];
        
        self.textNColor1    = [UIColor labelColor];
        self.textNColor2    = [UIColor secondaryLabelColor];
        
    } else {
        self.bgColor1       = [UIColor whiteColor];
        self.bgColor2       = [UIColor whiteColor];
        self.bgColor3       = [UIColor whiteColor];
        self.bgColor4       = [UIColor whiteColor];
        
        self.separatorColor = [UIColor lightGrayColor];
        
        self.labelColor     = [UIColor blackColor];
        
        self.textNColor1    = [UIColor blackColor];
        self.textNColor2    = [UIColor grayColor];
    }
    
    self.textSColor     = self.themeColor;
    self.colorRed       = [UIColor systemRedColor];
    
}

@end
