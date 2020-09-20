//
//  MusicInfoCell.m
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.
//

#import "MusicInfoCell.h"

@implementation MusicInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(MusicInfoCellType)type {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _type = type;
        self.contentView.backgroundColor = App_bgColor2;
        [self addViews];
    }
    return self;
}

- (void)addViews {
    self.addBt = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame =  CGRectMake(0, 0, 30, 30);
        [self.contentView addSubview:button];
        
        button;
    });
    for (int i = 0; i<2; i++) {
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
                oneL.font      = [UIFont systemFontOfSize:15];
                oneL.textColor = [UIColor blackColor];
                self.titelL    = oneL;
                break;
            }
            case 1:{
                oneL.font      = [UIFont systemFontOfSize:13];
                oneL.textColor = [UIColor grayColor];
                self.timeL     = oneL;
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
    
    [self.addBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        switch (self.type) {
            case MusicInfoCellTypeDefault:{
                make.width.height.mas_equalTo(0);
                break;
            }
            case MusicInfoCellTypeAdd:{
                [self.addBt setImage:[UIImage imageNamed:@"add_gray"] forState:UIControlStateNormal];
                make.width.height.mas_equalTo(30);
                break;
            }
        }
        
        make.left.mas_equalTo(15);
    }];
    
    [self.rightIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.size.mas_equalTo(self.rightIV.image.size);
        //make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.mas_equalTo(0);
    }];
    
    [self.titelL mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(7);
        make.height.mas_equalTo(20);
        switch (self.type) {
            case MusicInfoCellTypeDefault:{
                make.left.mas_equalTo(self.addBt.mas_right);
                break;
            }
            case MusicInfoCellTypeAdd:{
                make.left.mas_equalTo(self.addBt.mas_right).mas_offset(10);
                break;
            }
        }
        make.right.mas_lessThanOrEqualTo(self.rightIV.mas_left).mas_offset(-5);
    }];
    [self.timeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titelL.mas_left);
        make.bottom.mas_equalTo(-5);
        make.height.mas_equalTo(20);
        make.right.mas_lessThanOrEqualTo(self.rightIV.mas_left).mas_offset(-5);
    }];
}

@end
