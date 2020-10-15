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
#import "LrcKuGou.h"
#import "LrcTool.h"

#import <PoporUI/UIDevice+pScreenSize.h>
//#import <PoporImageBrower/PoporImageBrower.h>

static CGFloat MPBTimeLabelWidth0 = 38;
static CGFloat MPBTimeLabelWidth1 = 57;

@interface MusicPlayBar ()

@property (nonatomic        ) BOOL isX;
@property (nonatomic, strong) NSArray * orderImageArray;
@property (nonatomic        ) CGFloat sliderImageWH;

@property (nonatomic, copy  ) NSString * lastMusicTitle;

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
        self.backgroundColor = App_bgColor1;
        [self addViews];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self resumeLastStatus];
        });
    }
    return self;
}

- (void)addViews {
#if TARGET_OS_MACCATALYST
    int bottomMargin = 10;
#else
    int bottomMargin = [UIDevice safeBottomMargin];
#endif
    
    self.frame = CGRectMake(0, 0, PSCREEN_SIZE.width, 130 + bottomMargin);
    
    {
        self.sliderTimeL = ({
            UILabel * l = [UILabel new];
            l.frame              = CGRectMake(0, 0, 60, 30);
            l.backgroundColor    = App_bgColor1;
            l.font               = [UIFont systemFontOfSize:15];
            l.textColor          = ColorThemeBlue1;
            l.textAlignment      = NSTextAlignmentCenter;
            l.hidden             = YES;
            l.layer.cornerRadius = 6;
            l.clipsToBounds      = YES;
            
            [self addSubview:l];
            l;
        });
        
        self.sliderImageWH = 24;
        
        self.slider = ({
            UISlider * slider = [UISlider new];
            slider.maximumValue   = 1.0;
            slider.minimumValue   = 0.0;
            slider.tintColor      = App_themeColor;
            slider.minimumTrackTintColor = App_themeColor;
            slider.maximumTrackTintColor = App_separatorColor;
            
            // slider.thumbTintColor = [UIColor redColor];
            UIImage *image = [UIImage imageFromColor:ColorThemeBlue1 size:CGSizeMake(self.sliderImageWH, self.sliderImageWH) corner:self.sliderImageWH/2];
            [slider setThumbImage:image forState:UIControlStateNormal];
            
            [self addSubview:slider];
            
            slider;
        });
        
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
                
                float x = self.slider.frame.origin.x  +self.sliderImageWH/2 +(self.slider.width -self.sliderImageWH) *self.slider.value;
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
                oneL.text = @"请通过wifi添加音乐文件，新建歌单。"; //欢迎使用：
                self.songInfoL = oneL;
                break;
            }
            case 1:{
                oneL.font = [UIFont systemFontOfSize:13];
                oneL.text = @"--:--";
                oneL.textAlignment = NSTextAlignmentLeft;
                self.timeCurrentL = oneL;
                break;
            }
            case 2:{
                oneL.font = [UIFont systemFontOfSize:13];
                oneL.text = @"--:--";
                oneL.textAlignment = NSTextAlignmentLeft;
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
        iv.image = [UIImage imageNamed:@"music_placeholder"];
        iv.userInteractionEnabled = YES;
        
        UITapGestureRecognizer * tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigIVAction)];
        [iv addGestureRecognizer:tapGR];
        
        [self addSubview:iv];
        iv;
    });
    {
        self.lineView = [UIView new];
        self.lineView.backgroundColor = App_separatorColor;
        
        [self addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(0.5);
        }];
    }
    
    CGFloat top = 6;
    CGFloat lW  = MPBTimeLabelWidth0;
    {   // 因为要不停的修改时间, 所以这里不能使用masonry, 会因此浪费大量cpu
        self.timeCurrentL.frame  = CGRectMake(15, top, lW, 20);
        self.timeDurationL.frame = CGRectMake(self.width -lW -self.timeCurrentL.x, top, lW, 20);
        self.slider.frame        = CGRectMake(self.timeCurrentL.right +5, top, self.timeDurationL.left -self.timeCurrentL.right - 10, 20);
        
        self.timeCurrentL.tag = MPBTimeLabelWidth0;
    }
    
    float width = 40;
    float height = 40;
    
    self.rewindBT.hidden = YES;
    self.forwardBT.hidden = YES;
    [self.songInfoL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.slider.bottom +10);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(self.exitPlaySearchLocalBT.mas_left).mas_offset(-5);
    }];
    // 退出播放搜素结果列表
    [self.exitPlaySearchLocalBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.songInfoL.mas_centerY);
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
        make.top.mas_equalTo(self.songInfoL.mas_bottom).mas_offset(7);
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
    
    //    if (playSearchLocalItem) {
    //        if (self.exitPlaySearchLocalBT) {
    //            [UIView animateWithDuration:0.15 animations:^{
    //                [self.exitPlaySearchLocalBT mas_updateConstraints:^(MASConstraintMaker *make) {
    //                    make.size.mas_equalTo(CGSizeMake(30, 30));
    //                }];
    //                [self.exitPlaySearchLocalBT.superview layoutIfNeeded];
    //            } completion:^(BOOL finished) {
    //
    //            }];
    //
    //        }
    //    }else{
    //        [self.exitPlaySearchLocalBT mas_updateConstraints:^(MASConstraintMaker *make) {
    //            make.size.mas_equalTo(CGSizeZero);
    //        }];
    //        [self.exitPlaySearchLocalBT.superview layoutIfNeeded];
    //    }
}

- (void)updateTimeCurrentFrameTime:(CGFloat)time {
    CGFloat widthTag = 0;
    if (time >= 3600) {
        widthTag = MPBTimeLabelWidth1;
    } else {
        widthTag = MPBTimeLabelWidth0;
    }
    
    if (self.timeCurrentL.tag != widthTag) {
        self.timeCurrentL.tag = widthTag;
        
        [UIView animateWithDuration:0.1 animations:^{
            self.timeCurrentL.width = widthTag;
            self.slider.frame        = CGRectMake(self.timeCurrentL.right +5, self.slider.y, self.timeDurationL.left -self.timeCurrentL.right - 10, 20);
        }];
    }
}

- (void)updateTimeDurationFrameTime:(CGFloat)time {
    CGFloat widthTag = 0;
    if (time >= 3600) {
        widthTag = MPBTimeLabelWidth1;
    } else {
        widthTag = MPBTimeLabelWidth0;
    }
    
    if (self.timeDurationL.tag != widthTag) {
        self.timeDurationL.tag = widthTag;
        [UIView animateWithDuration:0.1 animations:^{
            self.timeDurationL.frame = CGRectMake(self.width -widthTag -self.timeCurrentL.x, self.timeDurationL.y, widthTag, self.timeDurationL.height);
            self.slider.frame        = CGRectMake(self.timeCurrentL.right +5, self.slider.y, self.timeDurationL.left -self.timeCurrentL.right - 10, 20);
        }];
    }
}

- (void)updateProgressSectionFrame {
    if (self.timeDurationL.right == self.width -self.timeCurrentL.x) { // 如果相同, 有可能是进去了全屏模式
        // dispatch_async(dispatch_get_main_queue(), ^{
        //     [self updateProgressSectionFrame];
        // });
        
    } else {
        self.timeDurationL.right = self.width -self.timeCurrentL.x;
        self.slider.frame        = CGRectMake(self.timeCurrentL.right +5, self.slider.y, self.timeDurationL.left -self.timeCurrentL.right - 10, 20);
    }
}

- (void)playLocalListArray:(NSArray<FileEntity> *)itemArray folder:(NSString * _Nullable)folderName type:(McPlayType)playType at:(NSInteger)index {
    [self.mplt.currentTempList removeAllObjects];
    [self.mplt.currentTempList addObjectsFromArray:itemArray];
    
    self.mplt.currentWeakList = self.mplt.currentTempList;
    self.playBT.selected      = YES;
    self.playSearchLocalItem  = YES;
    
    if (itemArray.count > 0) {
        self.currentItem = self.mplt.currentWeakList[index];
        [self playItem:self.currentItem autoPlay:YES];
    }
    
    // 刷新item
    [self updateConfigIndex:index];
    
    self.mplt.config.playType = McPlayType_local;
    
    // 当folderName为空的时候, 可能是搜索的播放, 则不进行任何记录
    if (folderName.length > 0) {
        self.mplt.config.localFolderName = folderName;
        self.mplt.config.localMusicName  = self.currentItem.fileName;
    }
}

- (void)playSongListEntity:(MusicPlayListEntity *)listEntity at:(NSInteger)index {
    if (self.mplt.currentWeakList != listEntity.itemArray) {
        self.mplt.currentWeakList = listEntity.itemArray;
    }
    self.playBT.selected     = YES;
    if (self.isPlaySearchLocalItem) {
        self.playSearchLocalItem = NO;
        //AlertToastTitle(@"退出 [搜索歌单] 模式");
    }
    
    if (listEntity.itemArray.count > 0) {
        self.currentItem = self.mplt.currentWeakList[index];
        [self playItem:self.currentItem autoPlay:YES];
    }
    
    NSInteger currentListIndex = [self.mplt.list.songListArray indexOfObject:listEntity];
    if (self.mplt.config.songIndexList != currentListIndex) {
        self.mplt.config.songIndexList = currentListIndex;
    }
    
    self.mplt.config.playType      = McPlayType_songList;
    self.mplt.config.songIndexItem = index;
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
            [self playItem:self.currentItem autoPlay:YES];
        }else{
            [self playItem:self.currentItem autoPlay:YES];
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
        [self playItem:self.currentItem autoPlay:YES];
        
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
        [self playItem:self.currentItem autoPlay:YES];
        
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
        if (self.mplt.config.songIndexList >= 0) {
            MusicPlayListEntity * le = self.mplt.list.songListArray[self.mplt.config.songIndexList];
            itemIndex = [le.itemArray indexOfObject:self.currentItem];
            
            if (itemIndex != INTMAX_MAX && itemIndex >= 0) {
                self.mplt.config.songIndexItem = itemIndex;
            }
        }
        //AlertToastTitle(@"当前播放歌单为: 搜索结果");
    }else{
        self.mplt.config.songIndexItem = itemIndex;
    }
}

- (void)rewindBTEvent {
    
}

- (void)forwardBTEvent {
    
}

- (void)exitPlaySearchLocalBTAction {
    self.playSearchLocalItem = NO;
    
    if (self.mplt.config.songIndexList >= 0) {
        MusicPlayListEntity * le = self.mplt.list.songListArray[self.mplt.config.songIndexList];
        NSInteger row = [le.itemArray indexOfObject:self.currentItem];
        if (row != INTMAX_MAX) {
            [self playSongListEntity:le at:row];
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
}

#pragma mark - 恢复上次数据
- (void)resumeLastStatus {
    
    switch (self.mplt.config.playType) {
        case McPlayType_songList: {
            if (self.mplt.config.songIndexList >= 0 && self.mplt.list.songListArray > 0) {
                
                MusicPlayListEntity * listEntity = self.mplt.list.songListArray[self.mplt.config.songIndexList];
                NSInteger             index      = self.mplt.config.songIndexItem;
                
                if (self.mplt.currentWeakList != listEntity.itemArray) {
                    self.mplt.currentWeakList = listEntity.itemArray;
                }
                if (listEntity.itemArray.count > 0) {
                    self.currentItem = self.mplt.currentWeakList[index];
                    [self playItem:self.currentItem autoPlay:NO];
                }
            }
            break;
        }
        case McPlayType_local: {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MGJRouter openURL:MUrl_resumePlayItem_local];
            });
            
            break;
        }
        case McPlayType_searchLocal:
        case McPlayType_searchSongList:{
            
            break;
        }
        default:
            break;
    }
    
    [self.orderBT setImage:LmImageThemeBlue1(McPlayOrderImageArray[self.mplt.config.playOrder]) forState:UIControlStateNormal];
    
}

- (void)playItem:(FileEntity *)item autoPlay:(BOOL)autoPlay {
    [self.mpt playItem:self.currentItem autoPlay:autoPlay];
}

//- (void)updateLyric {
//    if ([self.lastMusicTitle isEqualToString:self.currentItem.musicName] && self.musicLyricDic) {
//        return;
//    }
//    self.musicLyricDic   = nil;
//    self.musicLyricArray = nil;
//    self.lastMusicTitle  = self.currentItem.musicName;
//
//    //NSString * musicName = @"世界第一等";
//    NSString * musicName = self.lastMusicTitle;
//    @weakify(self);
//    [LrcFetch getLrcList:self.lastMusicTitle finish:^(LrcListEntity * _Nullable listEntity) {
//        if (listEntity.result.count > 0) {
//            LrcListUnitEntity * ue = listEntity.result.firstObject;
//            [LrcFetch getLrcDetail:musicName url:ue.lrc finish:^(NSString *string) {
//                @strongify(self);
//                NSDictionary * originDic = [LrcTool parselrc:string];
//
//                NSMutableArray * originArray = [NSMutableArray new];
//                NSArray * timeTextArray = originDic.allKeys;
//                for (NSString * timeText in timeTextArray) {
//
//                    LrcDetailEntity * entity = [LrcDetailEntity new];
//                    entity.timeText = timeText;
//                    entity.lrc      = originDic[timeText];;
//
//                    NSRange range = [timeText rangeOfString:@":"];
//                    NSInteger mm  = [timeText substringToIndex:range.location].integerValue;
//                    NSInteger ss  = [timeText substringFromIndex:range.location +1].integerValue;
//                    entity.time   = mm*60 +ss;
//
//                    [originArray addObject:entity];
//                }
//
//                self.musicLyricArray = [originArray sortedArrayUsingComparator:^NSComparisonResult(LrcDetailEntity * obj1, LrcDetailEntity * obj2) {
//                    //return [obj1.time compare:obj2.time]; //升序
//                    return obj1.time<obj2.time ? NSOrderedAscending:NSOrderedDescending;
//                }];
//
//
//                NSMutableDictionary * tempDic = [NSMutableDictionary new];
//                NSInteger count = self.musicLyricArray.count;
//                for (NSInteger row = 0; row<count; row++) {
//                    LrcDetailEntity * entity = self.musicLyricArray[row];
//                    entity.row = row;
//
//                    tempDic[entity.timeText] = entity;
//                }
//                self.musicLyricDic = tempDic;
//
//                NSDictionary * dic = @{@"lrcArray":self.musicLyricArray};
//                [MGJRouter openURL:MUrl_updateLrcData withUserInfo:dic completion:nil];
//
//                // for (LrcDetailEntity * entity in self.musicLyricArray) {
//                //     [NSAssistant NSLogEntity:entity];
//                //     NSLog(@"\n ");
//                // }
//            }];
//        } else {
//            [MGJRouter openURL:MUrl_updateLrcData];
//        }
//    }];
//
//
//}

- (void)updateLyricKugou {
    
    if ([self.lastMusicTitle isEqualToString:self.currentItem.musicName] && self.musicLyricDic) {
        return;
    }
    self.musicLyricDic   = nil;
    self.musicLyricArray = nil;
    self.lastMusicTitle  = self.currentItem.musicName;
    
    @weakify(self);
    [LrcKuGou getLrcList:self.currentItem finish:^(LrcKugouListEntity * _Nullable listEntity) {
        @strongify(self);
        if (listEntity.lrcArray.count > 0) {
            LrcKugouListUnitEntity * ue = listEntity.lrcArray.firstObject;
            [LrcKuGou getLrcDetail:self.currentItem id:ue.id accesskey:ue.accesskey finish:^(NSString *string) {
                @strongify(self);
                NSDictionary * originDic = [LrcTool parselrc:string];
                
                NSMutableArray * originArray = [NSMutableArray new];
                NSArray * timeTextArray = originDic.allKeys;
                for (NSString * timeText in timeTextArray) {
                    
                    LrcDetailEntity * entity = [LrcDetailEntity new];
                    entity.timeText = timeText;
                    entity.lrc      = originDic[timeText];;
                    
                    NSRange range = [timeText rangeOfString:@":"];
                    NSInteger mm  = [timeText substringToIndex:range.location].integerValue;
                    NSInteger ss  = [timeText substringFromIndex:range.location +1].integerValue;
                    entity.time   = mm*60 +ss;
                    
                    [originArray addObject:entity];
                }
                
                self.musicLyricArray = [originArray sortedArrayUsingComparator:^NSComparisonResult(LrcDetailEntity * obj1, LrcDetailEntity * obj2) {
                    //return [obj1.time compare:obj2.time]; //升序
                    return obj1.time<obj2.time ? NSOrderedAscending:NSOrderedDescending;
                }];
                
                
                NSMutableDictionary * tempDic = [NSMutableDictionary new];
                NSInteger count = self.musicLyricArray.count;
                for (NSInteger row = 0; row<count; row++) {
                    LrcDetailEntity * entity = self.musicLyricArray[row];
                    entity.row = row;
                    
                    tempDic[entity.timeText] = entity;
                }
                self.musicLyricDic = tempDic;
                
                NSDictionary * dic = @{@"lrcArray":self.musicLyricArray};
                [MGJRouter openURL:MUrl_updateLrcData withUserInfo:dic completion:nil];
                
                // for (LrcDetailEntity * entity in self.musicLyricArray) {
                //     [NSAssistant NSLogEntity:entity];
                //     NSLog(@"\n ");
                // }
            }];
        } else {
            [MGJRouter openURL:MUrl_updateLrcData];
        }
        
    }];
    
}

- (void)showBigIVAction {
    [MGJRouter openURL:MUrl_showLrc];
}

//- (void)showBigIVAction1 {
//    if (!self.mpt.audioPlayer) {
//        return;
//    }
//    UIImage * smallImage = self.coverIV.image;
//    UIImage * bigImage   = [MusicPlayTool imageOfUrl:self.mpt.audioPlayer.url];
//    NSMutableArray * imageArray = [NSMutableArray new];
//
//    {
//        PoporImageBrowerEntity * entity = [PoporImageBrowerEntity new];
//        entity.smallImage = smallImage;
//        entity.bigImage   = bigImage;
//
//        [imageArray addObject:entity];
//    }
//
//
//    __weak typeof(self) weakSelf = self;
//    PoporImageBrower *photoBrower = [[PoporImageBrower alloc] initWithIndex:0 copyImageArray:imageArray presentVC:self.rootNC.topViewController originImageBlock:^UIImageView *(PoporImageBrower *browerController, NSInteger index) {
//
//        return weakSelf.coverIV;
//    } disappearBlock:^(PoporImageBrower *browerController, NSInteger index) {
//
//    } placeholderImageBlock:^UIImage *(PoporImageBrower *browerController) {
//        return nil;
//    }];
//
//    [photoBrower show];
//}

@end
