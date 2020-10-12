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
#define ColorThemeBlue1              [UIColor colorWithRed:0.2 green:0.752941 blue:0.745098 alpha:1] //0.2 0.752941 0.745098 1
#define LmImageThemeBlue1(imageName) [UIImage imageFromImage:[UIImage imageNamed:imageName] changecolor:ColorThemeBlue1]
#define LmImageLightGray(imageName)  [UIImage imageFromImage:[UIImage imageNamed:imageName] changecolor:[UIColor lightGrayColor]]
#define LmImageRed(imageName)        [UIImage imageFromImage:[UIImage imageNamed:imageName] changecolor:[UIColor redColor]]

//....................................................................................

#define App_themeColor     [ThemeColor share].themeColor

#define App_bgColor1       [ThemeColor share].bgColor1
#define App_bgColor2       [ThemeColor share].bgColor2
#define App_bgColor3       [ThemeColor share].bgColor3
#define App_bgColor4       [ThemeColor share].bgColor4

#define App_separatorColor [ThemeColor share].separatorColor

#define App_labelColor     [ThemeColor share].labelColor

#define App_textNColor     [ThemeColor share].textNColor
#define App_textNColor2    [ThemeColor share].textNColor2
#define App_textSColor     [ThemeColor share].textSColor

//....................................................................................

@interface ThemeColor : UIColor

@property (nonatomic        ) UIUserInterfaceStyle previousUserInterfaceStyle;

@property (nonatomic, strong) UIColor * themeColor;

@property (nonatomic, strong) UIColor *  _Nullable bgColor1;
@property (nonatomic, strong) UIColor *  _Nullable bgColor2;
@property (nonatomic, strong) UIColor *  _Nullable bgColor3;
@property (nonatomic, strong) UIColor *  _Nullable bgColor4;
 
@property (nonatomic, strong) UIColor *  _Nullable separatorColor;
 
@property (nonatomic, strong) UIColor *  _Nullable labelColor;
 
@property (nonatomic, strong) UIColor *  _Nullable textNColor;
@property (nonatomic, strong) UIColor *  _Nullable textNColor2;

@property (nonatomic, strong) UIColor *  _Nullable textSColor;

+ (instancetype)share;

@end

NS_ASSUME_NONNULL_END
