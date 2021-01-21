//
//  PoporAvPlayerTopBar.h
//  hywj
//
//  Created by popor on 2020/9/5.
//  Copyright © 2020 popor. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PoporAvPlayerTopBar : UIView

@property (nonatomic, strong) UIButton * rightBT;
@property (nonatomic, strong) UIButton * backBT;
@property (nonatomic, strong) UILabel  * titleL;

@property (nonatomic, copy  ) NSArray<UIButton *> * rightBtArray;

- (void)defalutMasonry;

- (void)updateRightBtArray:(NSArray<UIButton *> *)array xGap:(CGFloat)xGap btSize:(CGSize)btSize;

@end

NS_ASSUME_NONNULL_END
