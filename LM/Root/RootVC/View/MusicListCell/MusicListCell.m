//
//  MusicListCell.m
//  LM
//
//  Created by apple on 2019/4/2.
//  Copyright © 2019 popor. All rights reserved.
//

#import "MusicListCell.h"

@implementation MusicListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addViews];
    }
    return self;
}

- (void)addViews {
    self.playBt = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame =  CGRectMake(0, 0, 30, 30);
        [button setImage:[UIImage imageNamed:@"play_gray"] forState:UIControlStateNormal];
        [self addSubview:button];
        
        button;
    });
    for (int i = 0; i<1; i++) {
        UILabel * oneL = ({
            UILabel * l = [UILabel new];
            l.backgroundColor    = [UIColor clearColor];
            l.font               = [UIFont systemFontOfSize:15];
            l.textColor          = [UIColor darkGrayColor];
            
            [self addSubview:l];
            l;
        });
        
        [oneL setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        oneL.numberOfLines =0;
        
        switch (i) {
            case 0:{
                self.titelL = oneL;
                break;
            }
            default:
                break;
        }
    }
    
    [self.playBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(30);
        make.left.mas_equalTo(15);
    }];
    
    [self.titelL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(self.playBt.mas_right).mas_offset(10);
        make.height.mas_equalTo(20);
    }];

}

@end
