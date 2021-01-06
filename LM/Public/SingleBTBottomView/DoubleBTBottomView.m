//
//  DoubleBTBottomView.m
//  hywj
//
//  Created by popor on 2020/12/11.
//  Copyright © 2020 popor. All rights reserved.
//

#import "DoubleBTBottomView.h"

@implementation DoubleBTBottomView

- (instancetype)init {
    if (self = [super init]) {
        self.btGap    = -1;
        self.topGap   = -1;
        self.btHeight = -1;
        self.btCorner = -1;
        self.bt1_bt2Scale = -1;
        self.bt1Width = -1;
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)addViews {
    CGFloat btGap    = self.btGap    == -1 ? 12           :self.btGap;
    CGFloat topGap   = self.topGap   == -1 ? 15           :self.topGap;
    CGFloat btHeight = self.btHeight == -1 ? 45           :self.btHeight;
    CGFloat btCorner = self.btCorner == -1 ? btHeight/2.0 :self.btCorner;
    
    CGFloat height;
    if (self.direction == DoubleBTBottomViewDirection_horizon) {
        height = [UIDevice safeBottomMargin] +topGap*2 + btHeight;
    } else {
        height = [UIDevice safeBottomMargin] +topGap*2 + btHeight*2 +btGap;
    }
    self.frame = CGRectMake(0, 0, PSCREEN_SIZE.width, height);
    
    self.bt1 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
        
        btn.clipsToBounds = YES;
        btn.layer.cornerRadius = btCorner;
        
        [self addSubview:btn];
        
        btn;
    });
    self.bt2 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
        
        btn.clipsToBounds = YES;
        btn.layer.cornerRadius = btCorner;
        
        [self addSubview:btn];
        
        btn;
    });
    
    if (self.direction == DoubleBTBottomViewDirection_horizon) {
        [self.bt1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(topGap);
            make.left.mas_equalTo(20);
            
            make.height.mas_equalTo(btHeight);
            
            if (self.bt1Width >0) {
                make.width.mas_equalTo(self.bt1Width);
            }
        }];
        
        [self.bt2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bt1);
            make.left.mas_equalTo(self.bt1.mas_right).mas_offset(btGap);
            make.right.mas_equalTo(-20);
            
            if (self.bt1_bt2Scale > 0) {
                make.width.mas_equalTo(self.bt1).multipliedBy(self.bt1_bt2Scale);
            } else if (self.bt1Width > 0) {
                
            } else {
                make.width.mas_equalTo(self.bt1);
            }
            make.height.mas_equalTo(self.bt1);
        }];
    } else {
        [self.bt1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(topGap);
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.height.mas_equalTo(btHeight);
        }];
        
        [self.bt2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bt1.mas_bottom).mas_offset(self.btGap);
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.height.mas_equalTo(btHeight);
        }];
    }
    
    
    self.lineView = [UIView new];
    self.lineView.backgroundColor = PRGB16(0XF0F0F0);
    [self addSubview:self.lineView];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.insets(UIEdgeInsetsZero);
        make.height.mas_equalTo(0.5);
    }];
}

@end
