//
//  AppPrefix.h
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.
//

#ifndef AppPrefix_h
#define AppPrefix_h

#import <PoporFoundation/PoporFoundation.h>
#import <PoporUI/PoporUI.h>
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

static NSString * LmCacheKey    = @"LmCache";
static NSString * LmPlayListKey = @"list";
static NSString * LmConfigKey   = @"config";

//static UIColor * ColorThemeBlue1 = RGB16(0X36a5d7);
#define ColorThemeBlue1 RGB16(0X36a5d7)

#define LmImageThemeBlue1(imageName) [UIImage imageFromImage:[UIImage imageNamed:imageName] changecolor:ColorThemeBlue1]

#define LmImageLightGray(imageName) [UIImage imageFromImage:[UIImage imageNamed:imageName] changecolor:[UIColor lightGrayColor]]

#endif /* AppPrefix_h */
