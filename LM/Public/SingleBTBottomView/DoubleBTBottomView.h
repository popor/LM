//
//  DoubleBTBottomView.h
//  hywj
//
//  Created by popor on 2020/12/11.
//  Copyright © 2020 popor. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DoubleBTBottomViewDirection) {
    DoubleBTBottomViewDirection_horizon,
    DoubleBTBottomViewDirection_vertical,
};


@interface DoubleBTBottomView : UIView

@property (nonatomic        ) DoubleBTBottomViewDirection direction;// 默认为horizon
@property (nonatomic        ) CGFloat btGap;    // 默认为12
@property (nonatomic        ) CGFloat topGap;   // 默认为15

@property (nonatomic        ) CGFloat btHeight; // 默认为45
@property (nonatomic        ) CGFloat btCorner; // 默认为btHeight的一半

// 长宽比, 假如是水平方向的话
@property (nonatomic        ) CGFloat bt1_bt2Scale; // 默认为-1 优先1
@property (nonatomic        ) CGFloat bt1Width; // 默认为-1 , 优先2

@property (nonatomic, strong) UIButton *bt1;
@property (nonatomic, strong) UIButton *bt2;
@property (nonatomic, strong) UIView *lineView;

- (void)addViews;

@end

NS_ASSUME_NONNULL_END
