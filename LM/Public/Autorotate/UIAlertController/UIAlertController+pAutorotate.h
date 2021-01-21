//
//  UIAlertController+pAutorotate.h
//  PoporUI
//
//  Created by popor on 2020/11/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//作者：动力机车
//链接：https://www.jianshu.com/p/7942eae55100

@interface UIAlertController (pAutorotate)

@end

@interface UIAcPautorotate : NSObject

@property (nonatomic        ) BOOL rotateEnable; // 默认为NO
@property (nonatomic        ) UIInterfaceOrientationMask supportedInterfaceOrientations; // 默认为UIInterfaceOrientationMaskPortrait

+ (instancetype)share;

@end


NS_ASSUME_NONNULL_END
