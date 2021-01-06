//
//  SingleBTBottomView.m
//  linRunShengPi
//
//  Created by HuXiaoyu on 2018/3/28.
//  Copyright © 2018年 艾慧勇. All rights reserved.
//

#import "SingleBTBottomView.h"
#import "Masonry.h"

@implementation SingleBTBottomView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.frame = CGRectMake(0, 0, PSCREEN_SIZE.width, 75+[UIDevice safeBottomMargin]);
        
        CGFloat btHeight = 45;
        self.submitBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
                        
            btn.clipsToBounds = YES;
            btn.layer.cornerRadius = btHeight/2;
            
            [self addSubview:btn];
            
            btn;
        });
            
        
        [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.insets(UIEdgeInsetsMake(15, 20, 0, 20));
            make.height.mas_equalTo(btHeight);
        }];
        
        self.lineView = [UIView new];
        self.lineView.backgroundColor = PRGB16(0XF0F0F0);
        [self addSubview:self.lineView];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.insets(UIEdgeInsetsZero);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
}

@end
