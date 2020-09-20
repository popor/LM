//
//  SongListHeadView.m
//  LM
//
//  Created by popor on 2020/9/20.
//  Copyright © 2020 popor. All rights reserved.
//

#import "SongListHeadView.h"

@implementation SongListHeadView

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
                self.addBT = oneBT;
                [oneBT setTitle:@"新增" forState:UIControlStateNormal];
                break;
            }
            case 1: {
                self.editBT = oneBT;
                [oneBT setTitle:@"编辑" forState:UIControlStateNormal];
                [oneBT setTitle:@"完成" forState:UIControlStateSelected];
                
                
                break;
            }
            default:
                break;
        }
    }
    
    [self.addBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(self.editBT.mas_left).mas_offset(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(45);
    }];
    
    [self.editBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(-5);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(self.addBT);
    }];
}


@end
