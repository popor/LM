//
//  LocalMusicHeadView.m
//  LM
//
//  Created by popor on 2020/9/20.
//  Copyright © 2020 popor. All rights reserved.
//

#import "LocalMusicHeadView.h"

@implementation LocalMusicHeadView

- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self addViews];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)addViews {
    
    for (NSInteger i = 0; i<2; i++) {
        UIButton * oneBT = ({
            UIButton * oneBT = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [oneBT setTitleColor:ColorThemeBlue1 forState:UIControlStateNormal];
            oneBT.titleLabel.font = [UIFont systemFontOfSize:16];
            // oneBT.layer.cornerRadius = 5;
            // oneBT.layer.borderColor = [UIColor lightGrayColor].CGColor;
            // oneBT.layer.borderWidth = 1;
            // oneBT.clipsToBounds = YES;
            
            [self.contentView addSubview:oneBT];
            
            oneBT;
        });
        
        switch (i) {
            case 0: {
                self.openBT = oneBT;
#if TARGET_OS_MACCATALYST
                [oneBT setTitle:@" 打开 " forState:UIControlStateNormal];
#else
                [oneBT setTitle:@" WIFI " forState:UIControlStateNormal];
#endif
                
                break;
            }
            case 1: {
                self.freshBT = oneBT;
                [oneBT setTitle:@" 刷新 " forState:UIControlStateNormal];
                //[oneBT setTitle:@"完成" forState:UIControlStateSelected];
                break;
            }
            default:
                break;
        }
    }
    
    [self.openBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(self.freshBT.mas_left).mas_offset(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(45);
    }];
    
    [self.freshBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(-5);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(self.openBT);
    }];
}

@end
