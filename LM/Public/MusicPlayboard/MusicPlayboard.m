//
//  MusicPlayboard.m
//  LM
//
//  Created by apple on 2019/3/28.
//  Copyright © 2019 popor. All rights reserved.
//

#import "MusicPlayboard.h"

#import <PoporUI/UIDeviceScreen.h>

@interface MusicPlayboard ()

@property (nonatomic        ) BOOL isX;
@property (nonatomic, strong) NSArray * orderImageArray;

@end

@implementation MusicPlayboard

+ (MusicPlayboard *)share {
    static dispatch_once_t once;
    static MusicPlayboard * instance;
    dispatch_once(&once, ^{
        instance = [self new];
        
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        [self addViews];
    }
    return self;
}

- (void)addViews {
    int bottomMargin = [UIDeviceScreen safeBottomMargin];
    self.frame = CGRectMake(0, 0, ScreenSize.width, 84 + bottomMargin);
    
    for (int i = 0; i<2; i++) {
        UILabel * oneL = ({
            UILabel * l = [UILabel new];
            l.frame              = CGRectMake(0, 0, 0, 44);
            l.backgroundColor    = [UIColor clearColor];
            l.font               = [UIFont systemFontOfSize:15];
            l.textColor          = [UIColor darkGrayColor];
            
            l.numberOfLines      = 1;
            
            l.layer.cornerRadius = 5;
            l.layer.borderColor  = [UIColor lightGrayColor].CGColor;
            l.layer.borderWidth  = 1;
            l.clipsToBounds      = YES;
            
            [self addSubview:l];
            l;
        });
        switch (i) {
            case 0:{
                self.nameL = oneL;
                break;
            }
            case 1:{
                self.timeL = oneL;
                break;
            }
                
            default:
                break;
        }
    }
    self.orderImageArray = @[@"loop_random", @"loop_order", @"loop_single"];
    NSArray * imageN = @[@"big_play_button",  @"prev_song", @"next_song", @"rewind", @"forward", @"loop_random"];
    NSArray * imageS = @[@"big_pause_button", @"prev_song", @"next_song", @"rewind", @"forward", @"loop_random"];
    
    for (int i = 0; i<imageN.count; i++) {
        UIButton * oneBT = ({
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:imageN[i]] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:imageS[i]] forState:UIControlStateHighlighted];
            [self addSubview:button];
            
            button;
        });
        switch (i) {
            case 0:{
                [oneBT setImage:nil forState:UIControlStateHighlighted];
                [oneBT setImage:[UIImage imageNamed:imageS[i]] forState:UIControlStateSelected];
                self.playBT = oneBT;
                break;
            }
            case 1:{
                self.previousBT = oneBT;
                break;
            }
            case 2:{
                self.nextBT = oneBT;
                break;
            }
            case 3:{
                self.rewindBT = oneBT;
                break;
            }
            case 4:{
                self.forwardBT = oneBT;
                break;
            }
            case 5:{
                self.orderBT = oneBT;
                break;
            }
            default:
                break;
        }
        
        
    }
    
    float width = 40;
    float height = 40;
    [self.orderBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
        
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(0);
    }];
    
    [self.nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(self.orderBT.mas_left).mas_offset(-20);
        make.height.mas_equalTo(20);;
    }];
    
    [self.playBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
        
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(40);
    }];
    [self.rewindBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
        
        make.right.mas_equalTo(self.playBT.mas_left).mas_offset(-20);
        make.top.mas_equalTo(self.playBT.mas_top);
    }];
    [self.previousBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
        
        make.right.mas_equalTo(self.rewindBT.mas_left).mas_offset(-20);
        make.top.mas_equalTo(self.playBT.mas_top);
    }];
    [self.forwardBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
        
        make.left.mas_equalTo(self.playBT.mas_right).mas_offset(20);
        make.top.mas_equalTo(self.playBT.mas_top);
    }];
    [self.nextBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
        
        make.left.mas_equalTo(self.forwardBT.mas_right).mas_offset(20);
        make.top.mas_equalTo(self.playBT.mas_top);
    }];
    
}

@end
