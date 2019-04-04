//
//  MusicPlayBar.m
//  LM
//
//  Created by apple on 2019/3/28.
//  Copyright © 2019 popor. All rights reserved.
//

#import "MusicPlayBar.h"

#import "MusicPlayTool.h"
#import "MusicPlayListTool.h"

#import <PoporUI/UIDeviceScreen.h>

@interface MusicPlayBar ()

@property (nonatomic        ) BOOL isX;
@property (nonatomic, strong) NSArray * orderImageArray;

@end

@implementation MusicPlayBar

+ (MusicPlayBar *)share {
    static dispatch_once_t once;
    static MusicPlayBar * instance;
    dispatch_once(&once, ^{
        instance = [self new];
        
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        self.mpt  = MptShare;
        self.mplt = MpltShare;
        self.backgroundColor = [UIColor whiteColor];
        [self addViews];
    }
    return self;
}

- (void)addViews {
    int bottomMargin = [UIDeviceScreen safeBottomMargin];
    self.frame = CGRectMake(0, 0, ScreenSize.width, 130 + bottomMargin);
    
    {
        self.slider = [UISlider new];
        self.slider.maximumValue = 1.0;
        self.slider.minimumValue = 0.0;
        
        [self addSubview:self.slider];
        [self.slider addTarget:self action:@selector(sliderAction) forControlEvents:UIControlEventTouchUpInside];
    }
    for (int i = 0; i<3; i++) {
        UILabel * oneL = ({
            UILabel * l = [UILabel new];
            l.backgroundColor    = [UIColor clearColor];
            l.textColor          = [UIColor darkGrayColor];
            
            [self addSubview:l];
            l;
        });
        switch (i) {
            case 0:{
                oneL.font = [UIFont systemFontOfSize:14];
                
                oneL.layer.cornerRadius = 5;
                oneL.layer.borderColor  = [UIColor lightGrayColor].CGColor;
                oneL.layer.borderWidth  = 1;
                oneL.clipsToBounds      = YES;
                
                self.nameL = oneL;
                break;
            }
            case 1:{
                oneL.font = [UIFont systemFontOfSize:13];
                oneL.text = @"--:--";
                self.timeCurrentL = oneL;
                break;
            }
            case 2:{
                oneL.font = [UIFont systemFontOfSize:13];
                oneL.text = @"--:--";
                self.timeDurationL = oneL;
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
                
                [oneBT addTarget:self action:@selector(playBTEvent) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            case 1:{
                self.previousBT = oneBT;
                
                [oneBT addTarget:self action:@selector(previousBTEvent) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            case 2:{
                self.nextBT = oneBT;
                
                [oneBT addTarget:self action:@selector(nextBTEvent) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            case 3:{
                self.rewindBT = oneBT;
                
                [oneBT addTarget:self action:@selector(rewindBTEvent) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            case 4:{
                self.forwardBT = oneBT;
                
                [oneBT addTarget:self action:@selector(forwardBTEvent) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            case 5:{
                self.orderBT = oneBT;
                
                //[oneBT addTarget:self action:@selector(<#selector#>) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            default:
                break;
        }
        
    }
    
    self.coverIV = ({
        UIImageView * iv = [UIImageView new];
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = YES;
        
        [self addSubview:iv];
        iv;
    });
    {
        self.lineView = [UIView new];
        self.lineView.backgroundColor = ColorTV_separator;
        
        [self addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(0.5);
        }];
    }
    [self.timeCurrentL setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    self.timeCurrentL.numberOfLines =0;
    [self.timeCurrentL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self.slider.mas_centerY);
        make.height.mas_equalTo(15);
        make.width.mas_greaterThanOrEqualTo(40);
    }];
    [self.timeDurationL setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    self.timeDurationL.numberOfLines =0;
    [self.timeDurationL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self.slider.mas_centerY);
        make.height.mas_equalTo(15);
        make.width.mas_greaterThanOrEqualTo(40);
    }];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(6);
        make.left.mas_equalTo(self.timeCurrentL.mas_right).mas_offset(3);
        make.right.mas_equalTo(self.timeDurationL.mas_left).mas_offset(-3);
        make.height.mas_equalTo(20);
    }];
    
    float width = 40;
    float height = 40;
    [self.orderBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(20);
        
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.slider.mas_bottom).mas_offset(3);
    }];
    
    [self.nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.orderBT.mas_top);
        make.left.mas_equalTo(self.orderBT.mas_right).mas_offset(5);
        make.height.mas_equalTo(20);;
        make.width.mas_equalTo(200);
    }];
    [self.rewindBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
        
        make.left.mas_equalTo(self.nameL.mas_right).mas_offset(10);
        make.centerY.mas_equalTo(self.nameL.mas_centerY);
    }];
    [self.forwardBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
        
        make.left.mas_equalTo(self.rewindBT.mas_right).mas_offset(8);
        make.centerY.mas_equalTo(self.nameL.mas_centerY);
    }];
    
    [self.coverIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(self.orderBT.mas_bottom).mas_offset(5);
        make.width.height.mas_equalTo(60);
    }];
    
    [self.playBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
        
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(self.coverIV.mas_centerY);
    }];
    
    [self.previousBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
        
        make.right.mas_equalTo(self.playBT.mas_left).mas_offset(-20);
        //make.top.mas_equalTo(self.playBT.mas_top);
        make.centerY.mas_equalTo(self.coverIV.mas_centerY);
    }];

    [self.nextBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
        
        make.left.mas_equalTo(self.playBT.mas_right).mas_offset(20);
        //make.top.mas_equalTo(self.playBT.mas_top);
        make.centerY.mas_equalTo(self.coverIV.mas_centerY);
    }];
    
}

- (void)playTempArray:(NSArray *)itemArray at:(NSInteger)index {
    [self.mplt.currentTempList removeAllObjects];
    [self.mplt.currentTempList addObjectsFromArray:itemArray];
    self.mplt.currentWeakList = self.mplt.currentTempList;
    self.playBT.selected = YES;
    if (itemArray.count > 0) {
        self.currentItem = self.mplt.currentWeakList[index];
        [self.mpt playItem:self.currentItem];
    }
}

- (void)playRecordArray:(NSMutableArray *)itemArray at:(NSInteger)index {
    if (self.mplt.currentWeakList != itemArray) {
        self.mplt.currentWeakList = itemArray;
    }
    self.playBT.selected = YES;
    if (itemArray.count > 0) {
        self.currentItem = self.mplt.currentWeakList[index];
        [self.mpt playItem:self.currentItem];
    }
}

- (void)playBTEvent {
    if (self.mpt.audioPlayer.isPlaying) {
        [self pauseEvent];
    }else{
        [self playEvent];
    }
}

- (void)playEvent {
    //    if (!self.mplt.currentList) {
    //        if (self.mplt.list.array.count > 0) {
    //            MusicPlayListEntity * list = self.mplt.list.array[0];
    //            [self.mplt.currentList addObjectsFromArray:list.array];
    //        }
    //    }
    if (self.mplt.currentWeakList.count>0) {
        if (!self.currentItem) {
            self.currentItem = self.mplt.currentWeakList[0];
            [self.mpt playItem:self.currentItem];
        }else{
            [self.mpt playItem:self.currentItem];
        }
    }
}

- (void)pauseEvent {
    [self.mpt pauseEvent];
}

- (void)previousBTEvent {
    if (self.mplt.currentWeakList.count>0) {
        NSInteger index = 0;
        if (self.currentItem) {
            index = [self.mplt.currentWeakList indexOfObject:self.currentItem] - 1;
        }
        index =  (index + self.mplt.currentWeakList.count) % self.mplt.currentWeakList.count;
        self.currentItem = self.mplt.currentWeakList[index];
        [self.mpt playItem:self.currentItem];
    }
}

- (void)nextBTEvent {
    if (self.mplt.currentWeakList.count>0) {
        NSInteger index = 0;
        if (self.currentItem) {
            index = [self.mplt.currentWeakList indexOfObject:self.currentItem] + 1;
        }
        index =  index % self.mplt.currentWeakList.count;
        self.currentItem = self.mplt.currentWeakList[index];
        [self.mpt playItem:self.currentItem];
    }
}

- (void)rewindBTEvent {
    
}

- (void)forwardBTEvent {
    
}

- (void)sliderAction {
    NSLog(@"%f", self.slider.value);
    //    switch (self.slider.state) {
    //        case <#constant#>:
    //            <#statements#>
    //            break;
    //
    //        default:
    //            break;
    //    }
    [self.mpt playAtTimeScale:self.slider.value];
}

@end
