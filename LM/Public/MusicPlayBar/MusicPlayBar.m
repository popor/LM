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
#import <PoporImageBrower/PoporImageBrower.h>

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
        self.sliderTimeL = ({
            UILabel * l = [UILabel new];
            l.frame              = CGRectMake(0, 0, 120, 30);
            l.backgroundColor    = [UIColor clearColor];
            l.font               = [UIFont systemFontOfSize:15];
            l.textColor          = ColorThemeBlue1;
            l.textAlignment      = NSTextAlignmentCenter;
            l.hidden             = YES;
            
            [self addSubview:l];
            l;
        });
        
        self.slider = [UISlider new];
        self.slider.maximumValue = 1.0;
        self.slider.minimumValue = 0.0;
        self.slider.tintColor    = ColorThemeBlue1;
        self.slider.thumbTintColor = ColorThemeBlue1;
        [self addSubview:self.slider];
        
        @weakify(self);
        // 内部up
        [[self.slider rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self.mpt playAtTimeScale:self.slider.value];
            self.sliderSelected = NO;
            self.sliderTimeL.hidden  = YES;
        }];
        
        // 按下
        [[self.slider rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            self.sliderSelected = YES;
            self.sliderTimeL.hidden  = NO;
        }];
        // 外部up,取消
        [[self.slider rac_signalForControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchCancel] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            self.sliderSelected = NO;
            self.sliderTimeL.hidden  = YES;
        }];
        
        // 变更
        [[self.slider rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            if (self.sliderSelected && self.mpt.audioPlayer.duration > 0) {
                int time = self.mpt.audioPlayer.duration * self.slider.value;
                self.sliderTimeL.text = [self.mpt stringFromTime:time];
                
                float x = self.slider.frame.origin.x + self.slider.width*self.slider.value;
                self.sliderTimeL.center = CGPointMake(x, -40);
            }
        }];
    }
    for (int i = 0; i<3; i++) {
        UILabel * oneL = ({
            UILabel * l = [UILabel new];
            l.backgroundColor    = [UIColor clearColor];
            l.textColor          = [UIColor darkGrayColor];
            l.textColor          = ColorThemeBlue1;
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
    NSArray * imageN = @[@"big_play_button",  @"prev_song", @"next_song", @"rewind", @"forward", @"loop_random", @"searchMode"];
    NSArray * imageS = @[@"big_pause_button", @"prev_song", @"next_song", @"rewind", @"forward", @"loop_random", @"searchMode"];
    
    for (int i = 0; i<imageN.count; i++) {
        UIButton * oneBT = ({
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            if (i == 0) {
                [button setImage:LmImageThemeBlue1(imageN[i]) forState:UIControlStateNormal];
                [button setImage:LmImageThemeBlue1(imageS[i]) forState:UIControlStateHighlighted];
            }else if(i == 6){
                [button setImage:LmImageRed(imageN[i]) forState:UIControlStateNormal];
                [button setImage:LmImageLightGray(imageS[i])  forState:UIControlStateHighlighted];
            } else{
                [button setImage:LmImageThemeBlue1(imageN[i]) forState:UIControlStateNormal];
                [button setImage:LmImageLightGray(imageS[i])  forState:UIControlStateHighlighted];
            }
            
            [self addSubview:button];
            
            button;
        });
        switch (i) {
            case 0:{
                [oneBT setImage:nil forState:UIControlStateHighlighted];
                [oneBT setImage:LmImageThemeBlue1(imageS[i]) forState:UIControlStateSelected];
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
                [oneBT setImage:nil forState:UIControlStateHighlighted];
                
                [oneBT addTarget:self action:@selector(orderAction) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            case 6:{
                self.exitPlaySearchLocalBT = oneBT;
                
                [oneBT addTarget:self action:@selector(exitPlaySearchLocalBTAction) forControlEvents:UIControlEventTouchUpInside];
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
        iv.userInteractionEnabled = YES;
        
        UITapGestureRecognizer * tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigIVAction)];
        [iv addGestureRecognizer:tapGR];
        
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
        make.right.mas_equalTo(self.exitPlaySearchLocalBT.mas_left).mas_offset(-5);
    }];
    // 退出播放搜素结果列表
    [self.exitPlaySearchLocalBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nameL.mas_centerY);
        make.size.mas_equalTo(CGSizeZero);
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
        
        make.right.mas_equalTo(self.playBT.mas_left).mas_offset(-30);
        //make.top.mas_equalTo(self.playBT.mas_top);
        make.centerY.mas_equalTo(self.coverIV.mas_centerY);
    }];
    
    [self.nextBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
        
        make.left.mas_equalTo(self.playBT.mas_right).mas_offset(30);
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

- (void)setPlaySearchLocalItem:(BOOL)playSearchLocalItem {
    _playSearchLocalItem = playSearchLocalItem;
    
    if (playSearchLocalItem) {
        if (self.exitPlaySearchLocalBT) {
            [UIView animateWithDuration:0.15 animations:^{
                [self.exitPlaySearchLocalBT mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(30, 30));
                }];
                [self.exitPlaySearchLocalBT.superview layoutIfNeeded];
            } completion:^(BOOL finished) {
                
            }];
            
        }
    }else{
        [self.exitPlaySearchLocalBT mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeZero);
        }];
        [self.exitPlaySearchLocalBT.superview layoutIfNeeded];
    }
}

- (void)playTempArray:(NSArray *)itemArray at:(NSInteger)index {
    [self.mplt.currentTempList removeAllObjects];
    [self.mplt.currentTempList addObjectsFromArray:itemArray];
    
    self.mplt.currentWeakList = self.mplt.currentTempList;
    self.playBT.selected      = YES;
    self.playSearchLocalItem  = YES;
    
    if (itemArray.count > 0) {
        self.currentItem = self.mplt.currentWeakList[index];
        [self.mpt playItem:self.currentItem autoPlay:YES];
    }
    
    // 刷新item
    [self updateConfigIndex:index];
}

- (void)playMusicPlayListEntity:(MusicPlayListEntity *)listEntity at:(NSInteger)index {
    if (self.mplt.currentWeakList != listEntity.array) {
        self.mplt.currentWeakList = listEntity.array;
    }
    self.playBT.selected     = YES;
    if (self.isPlaySearchLocalItem) {
        self.playSearchLocalItem = NO;
        //AlertToastTitle(@"退出 [搜索歌单] 模式");
    }
    
    if (listEntity.array.count > 0) {
        self.currentItem = self.mplt.currentWeakList[index];
        [self.mpt playItem:self.currentItem autoPlay:YES];
    }
    
    NSInteger currentListIndex = [self.mplt.list.array indexOfObject:listEntity];
    if (self.mplt.config.indexList != currentListIndex) {
        self.mplt.config.indexList = currentListIndex;
        if (self.freshBlockRootVC) {
            self.freshBlockRootVC();
        }
    }
    
    self.mplt.config.indexItem = index;
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
        
        // 刷新item
        [self updateConfigIndex:index];
        
        // 刷新SongListDetailVC
        if (self.mpt.nextMusicBlock_SongListDetailVC) {
            self.mpt.nextMusicBlock_SongListDetailVC();
        }
    }
}

- (void)nextBTEvent {
    if (self.mplt.currentWeakList.count>0) {
        NSInteger index = [self getNextIndex];
        self.currentItem = self.mplt.currentWeakList[index];
        [self.mpt playItem:self.currentItem autoPlay:YES];
        
        self.playBT.selected = YES;
        
        // 刷新item
        [self updateConfigIndex:index];
        
        // 刷新SongListDetailVC
        if (self.mpt.nextMusicBlock_SongListDetailVC) {
            self.mpt.nextMusicBlock_SongListDetailVC();
        }
    }
}

- (NSInteger)getNextIndex {
    NSInteger index = 0;
    switch (self.mplt.config.playOrder) {
        case McPlayOrderRandom:{
            index = arc4random() % self.mplt.currentWeakList.count;
            break;
        }
        case McPlayOrderNormal:
            case McPlayOrderSingle:
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
    switch (self.mplt.config.playOrder) {
        case McPlayOrderRandom:{
            index = arc4random() % self.mplt.currentWeakList.count;
            break;
        }
        case McPlayOrderNormal:
        case McPlayOrderSingle:
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

- (void)updateConfigIndex:(NSInteger)itemIndex {
    if (self.isPlaySearchLocalItem) {
        // 假如播放的是搜索或者本地 音乐的话
        if (self.mplt.config.indexList >= 0) {
            MusicPlayListEntity * le = self.mplt.list.array[self.mplt.config.indexList];
            itemIndex = [le.array indexOfObject:self.currentItem];
            
            if (itemIndex != INTMAX_MAX && itemIndex >= 0) {
                self.mplt.config.indexItem = itemIndex;
                [self.mplt updateConfig];
            }
        }
        //AlertToastTitle(@"当前播放歌单为: 搜索结果");
    }else{
        self.mplt.config.indexItem = itemIndex;
        [self.mplt updateConfig];
    }
}

- (void)rewindBTEvent {
    
}

- (void)forwardBTEvent {
    
}

- (void)exitPlaySearchLocalBTAction {
    self.playSearchLocalItem = NO;
    
    if (self.mplt.config.indexList >= 0) {
        MusicPlayListEntity * le = self.mplt.list.array[self.mplt.config.indexList];
        NSInteger row = [le.array indexOfObject:self.currentItem];
        if (row != INTMAX_MAX) {
            [self playMusicPlayListEntity:le at:row];
            AlertToastTitle(@"退出 [搜索歌单] 模式");
        }else{
            AlertToastTitle(@"未在当前个当中找到 当前音乐");
        }
    }else{
        AlertToastTitle(@"未在当前个当中找到 当前音乐");
    }
}

- (void)orderAction {
    self.mplt.config.playOrder = (self.mplt.config.playOrder + 1)%McPlayOrderImageArray.count;
    
    [self.orderBT setImage:LmImageThemeBlue1(McPlayOrderImageArray[self.mplt.config.playOrder]) forState:UIControlStateNormal];
    [self.mplt updateConfig];
}

#pragma mark - 恢复上次数据
- (void)resumeLastStatus{
    
    if (self.mplt.config.indexList >= 0 && self.mplt.list.array > 0) {
        [self resumeMusicPlayListEntity:self.mplt.list.array[self.mplt.config.indexList]  at:self.mplt.config.indexItem];
        
        //[self playMusicPlayListEntity:self.mplt.list.array[self.mplt.config.listIndex]  at:self.mplt.config.itemIndex];
    }
    
    [self.orderBT setImage:LmImageThemeBlue1(McPlayOrderImageArray[self.mplt.config.playOrder]) forState:UIControlStateNormal];
    
}

- (void)showBigIVAction {
    if (!self.mpt.audioPlayer) {
        return;
    }
    UIImage * smallImage = self.coverIV.image;
    UIImage * bigImage   = [MusicPlayTool imageOfUrl:self.mpt.audioPlayer.url];
    NSMutableArray * imageArray = [NSMutableArray new];
    
    {
        PoporImageBrowerEntity * entity = [PoporImageBrowerEntity new];
        entity.smallImage = smallImage;
        entity.bigImage   = bigImage;
        
        [imageArray addObject:entity];
    }
    
    
    __weak typeof(self) weakSelf = self;
    PoporImageBrower *photoBrower = [[PoporImageBrower alloc] initWithIndex:0 copyImageArray:imageArray presentVC:self.rootNC.topViewController originImageBlock:^UIImageView *(PoporImageBrower *browerController, NSInteger index) {
        
        return weakSelf.coverIV;
    } disappearBlock:^(PoporImageBrower *browerController, NSInteger index) {
        
    } placeholderImageBlock:^UIImage *(PoporImageBrower *browerController) {
        return nil;
    }];
    
    [photoBrower show];
}

@end
