//
//  ThemeColor.h
//  LM
//
//  Created by popor on 2020/9/20.
//  Copyright © 2020 popor. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//....................................................................................
#define LmImageThemeBlue1(imageName) [UIImage imageFromImage:[UIImage imageNamed:imageName] changecolor:App_colorTheme]
#define LmImageLightGray(imageName)  [UIImage imageFromImage:[UIImage imageNamed:imageName] changecolor:[UIColor lightGrayColor]]
#define LmImageRed(imageName)        [UIImage imageFromImage:[UIImage imageNamed:imageName] changecolor:[UIColor redColor]]

//....................................................................................

#define App_colorTheme     [ThemeColor share].themeColor

#define App_colorBg1       [ThemeColor share].bgColor1
#define App_colorBg2       [ThemeColor share].bgColor2
#define App_colorBg3       [ThemeColor share].bgColor3
#define App_colorBg4       [ThemeColor share].bgColor4

#define App_colorSeparator [ThemeColor share].separatorColor

#define App_colorLabel     [ThemeColor share].labelColor

#define App_colorTextN1    [ThemeColor share].textNColor1
#define App_colorTextN2    [ThemeColor share].textNColor2
#define App_colorTextS1    [ThemeColor share].textSColor
#define App_colorRed1      [ThemeColor share].colorRed

//....................................................................................

@interface ThemeColor : UIColor

@property (nonatomic        ) UIUserInterfaceStyle previousUserInterfaceStyle API_AVAILABLE(ios(12.0));

@property (nonatomic, strong) UIColor * themeColor;

@property (nonatomic, strong) UIColor *  _Nullable bgColor1;
@property (nonatomic, strong) UIColor *  _Nullable bgColor2;
@property (nonatomic, strong) UIColor *  _Nullable bgColor3;
@property (nonatomic, strong) UIColor *  _Nullable bgColor4;
 
@property (nonatomic, strong) UIColor *  _Nullable separatorColor;
 
@property (nonatomic, strong) UIColor *  _Nullable labelColor;
 
@property (nonatomic, strong) UIColor *  _Nullable textNColor1;
@property (nonatomic, strong) UIColor *  _Nullable textNColor2;

@property (nonatomic, strong) UIColor *  _Nullable textSColor;

@property (nonatomic, strong) UIColor *  _Nullable colorRed;

+ (instancetype)share;

@end

NS_ASSUME_NONNULL_END
