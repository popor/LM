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
        
        self.contentView.backgroundColor = App_colorBg4;
        [self addViews];
    }
    return self;
}

- (void)addViews {
    for (int i = 0; i<1; i++) {
        UILabel * oneL = ({
            UILabel * l = [UILabel new];
            l.backgroundColor    = [UIColor clearColor];
            l.font               = [UIFont systemFontOfSize:15];
            l.textColor          = [UIColor darkGrayColor];
            
            [self.contentView addSubview:l];
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
    
    self.rightIV = ({
        UIImageView * iv = [UIImageView new];
        iv.image = LmImageThemeBlue1(@"paly_sound");
        iv.hidden = YES;
        [self.contentView addSubview:iv];
        iv;
    });
    
    [self.rightIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-6);
        make.size.mas_equalTo(self.rightIV.image.size);
        make.centerY.mas_equalTo(0);
    }];
    
    [self.titelL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(20);
        make.right.mas_lessThanOrEqualTo(self.rightIV.mas_left).mas_offset(-10);
    }];
}

@end
