//
//  PoporAvPlayerTopBar.m
//  hywj
//
//  Created by popor on 2020/9/5.
//  Copyright © 2020 popor. All rights reserved.
//

#import "PoporAvPlayerTopBar.h"
#import "PoporAvPlayerBundle.h"
#import "PoporAVPlayerPrifix.h"
#import "PoporAvPlayerRecord.h"

@implementation PoporAvPlayerTopBar

- (instancetype)init {
    if (self = [super init]) {
        [self addViews];
    }
    return self;
}

- (void)addViews {
    self.rightBT = ({
        UIButton * oneBT = [UIButton buttonWithType:UIButtonTypeCustom];
        [oneBT setImage:PoporAvPlayerImage(@"pap_download") forState:UIControlStateNormal];
        [oneBT setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:oneBT];
        oneBT;
    });
    self.titleL = ({
        UILabel * oneL = [UILabel new];
        oneL.frame               = CGRectMake(0, 0, 0, kJPVideoPlayerControlTopBarBTHeight);
        oneL.backgroundColor     = [UIColor clearColor]; // ios8 之前
        oneL.font                = [UIFont systemFontOfSize:16];
        oneL.textColor           = [UIColor whiteColor];
        oneL.layer.masksToBounds = YES; // ios8 之后 lableLayer 问题
        oneL.numberOfLines       = 1;
        
        //oneL.backgroundColor     = [UIColor yellowColor]; // ios8 之前
        
        [self addSubview:oneL];
        oneL;
    });
    
    // backBT 位置后面增加, 因为和titleL用重叠, 方便用户点击返回.
    self.backBT = ({
        UIButton * oneBT = [UIButton buttonWithType:UIButtonTypeCustom];
        oneBT.frame =  CGRectMake(0, 0, 65, kJPVideoPlayerControlTopBarBTHeight);
        [oneBT setImage:PoporAvPlayerImage(@"pap_pop") forState:UIControlStateNormal];
        
        oneBT.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        oneBT.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        //oneBT.backgroundColor = UIColor.yellowColor;
        
        [self addSubview:oneBT];
        
        oneBT;
    });
    
    self.titleL.text = @"";
}

- (void)defalutMasonry {
    [self.backBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(self.backBT.width);
    }];
    
    [self.titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(self.backBT.mas_right).mas_offset(-30);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(self.rightBT.mas_left).mas_offset(-5);
    }];
    
    [self.rightBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backBT);
        make.right.mas_equalTo(-14);
        make.size.mas_equalTo(CGSizeMake(kJPVideoPlayerControlTopBarBTWidth, kJPVideoPlayerControlTopBarBTHeight));
    }];
}

- (void)updateRightBtArray:(NSArray<UIButton *> *)array xGap:(CGFloat)xGap btSize:(CGSize)btSize {
    if (array.count > 0) {
        self.rightBtArray = array;
        
        if (CGSizeEqualToSize(btSize, CGSizeZero)) {
            btSize = CGSizeMake(kJPVideoPlayerControlTopBarBTWidth, kJPVideoPlayerControlTopBarBTHeight);
        }
        
        [self.rightBT removeFromSuperview];
        
        for (NSInteger i = 0; i<array.count; i++) {
            UIButton * bt = array[i];
            [self addSubview:bt];
            
            if (i == 0) {
                [bt mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.backBT);
                    make.right.mas_equalTo(-14);
                    make.size.mas_equalTo(btSize);
                }];
            } else {
                UIButton * preBT = array[i-1];
                [bt mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.backBT);
                    make.right.mas_equalTo(preBT.mas_left).mas_offset(-xGap);
                    make.size.mas_equalTo(btSize);
                }];
            }
        }
        
        UIButton * lastBT = array.lastObject;
        if (lastBT) {
            [self.titleL mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(lastBT.mas_left).mas_offset(-5);
            }];
        }
    }
}

@end
