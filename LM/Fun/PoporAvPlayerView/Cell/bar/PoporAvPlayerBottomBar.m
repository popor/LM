//
//  PoporAvPlayerBottomBar.m
//  hywj
//
//  Created by popor on 2020/9/5.
//  Copyright © 2020 popor. All rights reserved.
//

#import "PoporAvPlayerBottomBar.h"
#import "PoporAvPlayerBundle.h"
#import "PoporAVPlayerPrifix.h"
#import "PoporAvPlayerRecord.h"

@interface PoporAvPlayerBottomBar ()
@property (nonatomic, weak  ) PoporAvPlayerRecord * record;

@end

@implementation PoporAvPlayerBottomBar

- (instancetype)init {
    if (self = [super init]) {
        [self addViews];
    }
    return self;
}

- (void)addViews {
    self.record = [PoporAvPlayerRecord share];
    self.backgroundColor = [UIColor clearColor];
    
    self.progressSlider = ({
        UISlider * ps = [[UISlider alloc] init];
        static UIImage * pointImage;
        if (!pointImage) {
            pointImage= PoporAvPlayerImage(@"pap_point");
            // CGFloat width  = pointImage.size.width;
            // CGFloat height = 30;
            // pointImage = [UIImage imageFromImage:pointImage size:CGSizeMake(width, height) imageDrawRect:CGRectMake((width -pointImage.size.width)/2, (height -pointImage.size.height)/2, pointImage.size.width, pointImage.size.height) corner:0 borderWidth:0 borderColor:nil];
        }
         
        [ps setThumbImage:pointImage forState:UIControlStateNormal];
        [ps setMinimumTrackTintColor:[UIColor whiteColor]];
        [ps setMaximumTrackTintColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.25]];
        ps.value = 0.f;
        ps.continuous = YES;
        
        [self addSubview:ps];
        ps;
    });
    
    self.bufferProgressView = ({
        UIProgressView * pv = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        pv.progressTintColor = [UIColor colorWithWhite:1 alpha:0.5];
        pv.trackTintColor = [UIColor clearColor];
        
        [self addSubview:pv];
        pv;
    });
    
    self.playButton = ({
        UIButton *button = [UIButton new];
        [button setImage:PoporAvPlayerImage(@"pap_pause") forState:UIControlStateNormal];
        [button setImage:PoporAvPlayerImage(@"pap_play") forState:UIControlStateSelected];
        button.selected = YES;
        
        [self addSubview:button];
        button;
    });
    
    self.playButton_mini = ({
        UIButton *button = [UIButton new];
        [button setImage:PoporAvPlayerImage(@"pap_pause") forState:UIControlStateNormal];
        [button setImage:PoporAvPlayerImage(@"pap_play") forState:UIControlStateSelected];
        [self addSubview:button];
        
        button.selected = YES;
        button.hidden = YES;
        button;
    });
    
    
    self.previousBT = ({
        UIButton *button = [UIButton new];
        [button setImage:PoporAvPlayerImage(@"pap_previous") forState:UIControlStateNormal];
        [self addSubview:button];
        button;
    });
    
    self.nextBT = ({
        UIButton *button = [UIButton new];
        [button setImage:PoporAvPlayerImage(@"pap_next") forState:UIControlStateNormal];
        [self addSubview:button];
        button;
    });
    
    self.videoNumBT = ({
        UIButton *button = [UIButton new];
        
        [button setTitle:@"选集" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:button];
        button;
    });
    
    self.rateBT = ({
        UIButton *button = [UIButton new];
        [button setTitle:@"倍速" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:button];
        button;
    });
    
    self.definitionBT = ({
        UIButton *button = [UIButton new];
        [button setTitle:@"高清" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:button];
        button;
    });
    
    self.timeElapseL = ({
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentRight;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12];
        
        label.text = @"00:00";
        [self addSubview:label];
        label;
    });
    self.timeTotalL = ({
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12];
        
        label.text = @"00:00";
        [self addSubview:label];
        label;
    });
    
    self.landscapeButton = ({
        UIButton *button = [UIButton new];
        [button setImage:PoporAvPlayerImage(@"pap_landscape") forState:UIControlStateNormal];
        [button setImage:PoporAvPlayerImage(@"pap_portrait") forState:UIControlStateSelected];
        [self addSubview:button];
        button;
    });
}

- (void)defalutMasonry {
    CGFloat btWH = 30;
    CGFloat x    = 20;
    CGFloat xGap = 5;
    
    [self.previousBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(x);
        make.bottom.mas_equalTo(-6);
        make.size.mas_equalTo(CGSizeMake(btWH, btWH));
    }];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.previousBT.mas_right).mas_offset(xGap);
        make.bottom.mas_equalTo(self.previousBT);
        make.size.mas_equalTo(self.previousBT);
    }];
    
    [self.nextBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.playButton.mas_right).mas_offset(xGap);
        make.bottom.mas_equalTo(self.playButton);
        make.size.mas_equalTo(self.playButton);
    }];
    
    [self.landscapeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.previousBT);
        make.right.mas_equalTo(-x);
        make.size.mas_equalTo(self.previousBT);
    }];
    
    [self.rateBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.previousBT);
        
        make.right.mas_equalTo(self.landscapeButton.mas_left).mas_offset(-xGap);
        make.size.mas_equalTo(CGSizeMake(40, btWH));
    }];
    
    [self.videoNumBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.previousBT);
        
        make.right.mas_equalTo(self.rateBT.mas_left).mas_offset(-xGap);
        make.size.mas_equalTo(self.rateBT);
    }];
    
    [self.definitionBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.previousBT);
        
        make.right.mas_equalTo(self.videoNumBT.mas_left).mas_offset(-xGap);
        make.size.mas_equalTo(self.rateBT);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 因为lable要不停的修改位置, 使用masonry的话会不停的通知系统调运 [UIView layoutSubviews] 或者 [UIViewController viewDidLayoutSubviews]
    if (self.timeElapseL.tag == 0) {
        [self setTimeLabelValues:0 totalTime:0];
    } else {
        if (self.width != self.timeTotalL.right) {
            self.timeElapseL.tag = -1;
            [self setTimeLabelValues:self.record.elapsedSeconds totalTime:self.record.totalSeconds];
        }
    }
}

- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
    if ([self.delegate poporAvPlayerBottomBar:self currentTime:currentTime totalTime:totalTime]) {
        // 使用自定义
        
    } else {
        CGFloat textWidthLeft  = 50;
        CGFloat textWidthRight = 50;
        if (currentTime > 0 && totalTime > 0) {
            NSString * elapsedString = [NSDate clockText:currentTime];
            NSString * totalString   = [NSDate clockText:totalTime];
            
            self.timeElapseL.text = elapsedString;
            self.timeTotalL.text = totalString;
            if (currentTime >= 3600) {
                textWidthLeft = 65;
            }
            if (totalTime >= 3600) {
                textWidthRight = 65;
            }
        } else {
            self.timeElapseL.text = @"00:00";
            self.timeTotalL.text  = @"00:00";
        }
        
        if (self.timeElapseL.tag != textWidthLeft || self.timeTotalL.tag != textWidthRight) {
            self.timeElapseL.tag = textWidthLeft;
            self.timeTotalL.tag  = textWidthRight;
            
            self.timeElapseL.frame        = CGRectMake(5, self.height -self.previousBT.top -15, textWidthLeft, 20);
            self.timeTotalL.frame         = CGRectMake(self.width -textWidthRight, self.timeElapseL.top, textWidthRight, self.timeElapseL.height);
            self.progressSlider.frame     = CGRectMake(self.timeElapseL.right +5, self.timeElapseL.top, self.timeTotalL.left -self.timeElapseL.right -10, self.timeElapseL.height);
            self.bufferProgressView.frame = CGRectMake(self.progressSlider.x +3, self.timeElapseL.top +self.progressSlider.height/2 -2, self.progressSlider.width-6, 2);
        }
    }
}

- (void)setPlayBTStatus_playing {
    // || 符号
    self.playButton.selected      = NO;
    self.playButton_mini.selected = NO;
}

- (void)setPlayBTStatus_pause {
    // 三角符号
    self.playButton.selected      = YES;
    self.playButton_mini.selected = YES;
}

- (BOOL)isPlayBTStatus_playing {
    return !self.playButton.isSelected;
}

@end
