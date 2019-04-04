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
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self resumeLastStatus];
        });
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
        
        @weakify(self);
        // 内部up
        [[self.slider rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self.mpt playAtTimeScale:self.slider.value];
            self.sliderSelected = NO;
        }];
        
        // 按下
        [[self.slider rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            self.sliderSelected = YES;
        }];
        // 外部up,取消
        [[self.slider rac_signalForControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchCancel] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            self.sliderSelected = NO;
        }];
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
                [oneBT addTarget:self action:@selector(orderAction) forControlEvents:UIControlEventTouchUpInside];
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
    
    self.rewindBT.hidden = YES;
    self.forwardBT.hidden = YES;
    [self.nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.slider.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(-15);
    }];
    
    //    [self.nameL mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.mas_equalTo(self.slider.mas_bottom).mas_offset(10);
    //        make.left.mas_equalTo(15);
    //        make.height.mas_equalTo(20);
    //        make.right.mas_equalTo(self.rewindBT.mas_left).mas_offset(-5);
    //    }];
    //    [self.rewindBT mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.width.mas_equalTo(width);
    //        make.height.mas_equalTo(height);
    //
    //        make.right.mas_equalTo(self.forwardBT.mas_left).mas_offset(-10);
    //        make.centerY.mas_equalTo(self.nameL.mas_centerY);
    //    }];
    //    [self.forwardBT mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.width.mas_equalTo(width);
    //        make.height.mas_equalTo(height);
    //
    //        make.right.mas_equalTo(-15);
    //        make.centerY.mas_equalTo(self.nameL.mas_centerY);
    //    }];
    
    [self.coverIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(self.nameL.mas_bottom).mas_offset(7);
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
 
    // 顺序
    [self.orderBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
        
        make.right.mas_equalTo(-15);
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
        [self.mpt playItem:self.currentItem autoPlay:YES];
    }
    self.mplt.config.listIndex = -1;
    self.mplt.config.itemIndex = -1;
    [self.mplt updateConfig];
}

- (void)playMusicPlayListEntity:(MusicPlayListEntity *)listEntity at:(NSInteger)index {
    if (self.mplt.currentWeakList != listEntity.array) {
        self.mplt.currentWeakList = listEntity.array;
    }
    self.playBT.selected = YES;
    if (listEntity.array.count > 0) {
        self.currentItem = self.mplt.currentWeakList[index];
        [self.mpt playItem:self.currentItem autoPlay:YES];
    }
    
    self.mplt.config.listIndex = [self.mplt.list.array indexOfObject:listEntity];
    self.mplt.config.itemIndex = index;
    [self.mplt updateConfig];
}

// 恢复上次播放记录
- (void)resumeMusicPlayListEntity:(MusicPlayListEntity *)listEntity at:(NSInteger)index {
    if (self.mplt.currentWeakList != listEntity.array) {
        self.mplt.currentWeakList = listEntity.array;
    }
    if (listEntity.array.count > 0) {
        self.currentItem = self.mplt.currentWeakList[index];
        [self.mpt playItem:self.currentItem autoPlay:NO];
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
    if (self.mplt.currentWeakList.count>0) {
        if (!self.currentItem) {
            self.currentItem = self.mplt.currentWeakList[0];
            [self.mpt playItem:self.currentItem autoPlay:YES];
        }else{
            [self.mpt playItem:self.currentItem autoPlay:YES];
        }
    }
    self.playBT.selected = YES;
}

- (void)pauseEvent {
    [self.mpt pauseEvent];
    self.playBT.selected = NO;
}

- (void)previousBTEvent {
    if (self.mplt.currentWeakList.count>0) {
        NSInteger index = [self getPreviousIndex];
        self.currentItem = self.mplt.currentWeakList[index];
        [self.mpt playItem:self.currentItem autoPlay:YES];
        
        self.playBT.selected = YES;
        
        self.mplt.config.itemIndex = index;
        [self.mplt updateConfig];
    }
}

- (void)nextBTEvent {
    if (self.mplt.currentWeakList.count>0) {
        NSInteger index = [self getNextIndex];
        self.currentItem = self.mplt.currentWeakList[index];
        [self.mpt playItem:self.currentItem autoPlay:YES];
        
        self.playBT.selected = YES;
        
        self.mplt.config.itemIndex = index;
        [self.mplt updateConfig];
    }
}

- (NSInteger)getNextIndex {
    NSInteger index = 0;
    switch (self.mplt.config.order) {
        case MusicConfigOrderRandom:{
            index = arc4random() % self.mplt.currentWeakList.count;
            break;
        }
        case MusicConfigOrderNormal:
            case MusicConfigOrderSingle:
        default:{
            if (self.currentItem) {
                index = [self.mplt.currentWeakList indexOfObject:self.currentItem] + 1;
            }
            index =  index % self.mplt.currentWeakList.count;
            break;
        }
    }
    
    return index;
}

- (NSInteger)getPreviousIndex {
    NSInteger index = 0;
    switch (self.mplt.config.order) {
        case MusicConfigOrderRandom:{
            index = arc4random() % self.mplt.currentWeakList.count;
            break;
        }
        case MusicConfigOrderNormal:
        case MusicConfigOrderSingle:
        default:{
            if (self.currentItem) {
                index = [self.mplt.currentWeakList indexOfObject:self.currentItem] - 1;
            }
            index =  index % self.mplt.currentWeakList.count;
            break;
        }
    }
    
    return index;
}

- (void)rewindBTEvent {
    
}

- (void)forwardBTEvent {
    
}

- (void)orderAction {
    self.mplt.config.order = (self.mplt.config.order + 1)%MusicConfigOrderImageArray.count;
    [self.orderBT setImage:[UIImage imageNamed:MusicConfigOrderImageArray[self.mplt.config.order]] forState:UIControlStateNormal];
    [self.mplt updateConfig];
}

#pragma mark - 恢复上次数据
- (void)resumeLastStatus{
    
    if (self.mplt.config.listIndex >= 0 && self.mplt.list.array > 0) {
        [self resumeMusicPlayListEntity:self.mplt.list.array[self.mplt.config.listIndex]  at:self.mplt.config.itemIndex];
        
        //[self playMusicPlayListEntity:self.mplt.list.array[self.mplt.config.listIndex]  at:self.mplt.config.itemIndex];
    }
    
    [self.orderBT setImage:[UIImage imageNamed:MusicConfigOrderImageArray[self.mplt.config.order]] forState:UIControlStateNormal];
    
}

@end
