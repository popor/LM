//
//  MusicPlayBar.m
//  LM
//
//  Created by apple on 2019/3/28.
//  Copyright © 2019 popor. All rights reserved.
//

#import "MusicPlayBar.h"

#import "MusicPlayTool.h"
#import "MusicFolderEntity.h"
#import "LrcKuGou.h"
#import "LrcTool.h"

#import "FeedbackGeneratorTool.h"
#import "MusicConfig.h"
#import <PoporUI/UIDevice+pScreenSize.h>
//#import <PoporImageBrower/PoporImageBrower.h>

static CGFloat MPBTimeLabelWidth0 = 38;
static CGFloat MPBTimeLabelWidth1 = 57;

@interface MusicPlayBar ()

@property (nonatomic        ) BOOL isX;
@property (nonatomic, strong) NSArray * orderImageArray;
@property (nonatomic        ) CGFloat sliderImageWH;

@property (nonatomic, copy  ) NSString * lastMusicTitle;
@property (nonatomic, weak  ) MusicConfigShare * configShare;

@end

@implementation MusicPlayBar

+ (MusicPlayBar *)share {
    static dispatch_once_t once;
    static MusicPlayBar * instance;
    dispatch_once(&once, ^{
        instance = [self new];
        instance.configShare = [MusicConfigShare share];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        self.mpt  = MptShare;
        self.mplShare = [MusicPlayListEntityShare share];
        self.backgroundColor = App_colorBg1;
        
        self.playHistoryArray = [NSMutableArray<FileEntity> new];
        
        [self addViews];
    }
    return self;
}

- (void)addViews {
#if TARGET_OS_MACCATALYST
    CGFloat height          = 140;
    CGFloat CoverOrderWidth = 60;
#else
    CGFloat bottomMargin    = [UIDevice safeBottomMargin];
    CGFloat height          = 130 + ((bottomMargin >0) ? bottomMargin:10);
    CGFloat CoverOrderWidth = PSCREEN_SIZE.width == 320 ? 50:60;
#endif
    
    self.frame = CGRectMake(0, 0, PSCREEN_SIZE.width, height);
    
    {
        self.sliderTimeL = ({
            UILabel * l = [UILabel new];
            l.frame              = CGRectMake(0, 0, 60, 30);
            l.backgroundColor    = App_colorBg1;
            l.font               = [UIFont systemFontOfSize:15];
            l.textColor          = App_colorTheme;
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
            slider.tintColor      = App_colorTheme;
            slider.minimumTrackTintColor = App_colorTheme;
            slider.maximumTrackTintColor = App_colorSeparator;
            
            // slider.thumbTintColor = [UIColor redColor];
            UIImage *image = [UIImage imageFromColor:App_colorTheme size:CGSizeMake(self.sliderImageWH, self.sliderImageWH) corner:self.sliderImageWH/2];
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
                CGFloat time = self.mpt.audioPlayer.duration * self.slider.value;
                self.sliderTimeL.text = [self.mpt stringFromTime5:time];
                
                float x = self.slider.frame.origin.x  +self.sliderImageWH/2 +(self.slider.width -self.sliderImageWH) *self.slider.value;
                self.sliderTimeL.center = CGPointMake(x, -40);
                
                // 触感反馈
                static CGFloat lastTime;
                if (fabs(lastTime - time) >3) {
                    lastTime = time;
                    
                    FeedbackShakePhone
                }
            }
        }];
    }
    for (int i = 0; i<3; i++) {
        UILabel * oneL = ({
            UILabel * l = [UILabel new];
            l.backgroundColor    = [UIColor clearColor];
            l.textColor          = [UIColor darkGrayColor];
            l.textColor          = App_colorTheme;
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
    NSArray * imageN = @[@"big_play_button",  @"prev_song", @"next_song", @"rewind", @"forward", @"loop_random"];//@"searchMode"
    NSArray * imageS = @[@"big_pause_button", @"prev_song", @"next_song", @"rewind", @"forward", @"loop_random"];//@"searchMode"
    
    for (int i = 0; i<imageN.count; i++) {
        UIButton * oneBT = ({
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            if (i == 0) {
                {
                    NSLog(@"播放按钮右移 x 个像素");
                    UIImage * image = [UIImage imageNamed:imageN[i]];
                    image = [UIImage imageFromImage:image size:image.size imageDrawRect:CGRectMake(3, 0, image.size.width, image.size.height) corner:0 borderWidth:0 borderColor:nil];
                    image = [UIImage imageFromImage:image changecolor:App_colorTheme];
                    [button setImage:image forState:UIControlStateNormal];
                    //[button setImage:LmImageThemeBlue1(imageN[i]) forState:UIControlStateNormal];
                }
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
                self.playBT = oneBT;
                
                [oneBT setImage:nil forState:UIControlStateHighlighted];
                [oneBT setImage:LmImageThemeBlue1(imageS[i]) forState:UIControlStateSelected];
                
                oneBT.showsTouchWhenHighlighted = YES;
                
                oneBT.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                //oneBT.imageView.backgroundColor = UIColor.redColor;
                
                oneBT.frame = CGRectMake(0, 0, 60, 60);
                //UIImage * image = [UIImage imageFromColor:PRGBF(255, 255, 255, 0.8) size:oneBT.size corner:oneBT.width/2];
                UIImage * image = [UIImage imageFromColor:[App_colorTheme colorWithAlphaComponent:0.15] size:oneBT.size corner:oneBT.width/2];
                
                [oneBT setBackgroundImage:image forState:UIControlStateNormal];
                
                [oneBT addTarget:self action:@selector(playBTEvent) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            case 1:{
                self.previousBT = oneBT;
                oneBT.frame = CGRectMake(0, 0, 50, 50);
                [oneBT addTarget:self action:@selector(previousBTEvent) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            case 2:{
                self.nextBT = oneBT;
                oneBT.frame = CGRectMake(0, 0, 50, 50);
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
                oneBT.frame = CGRectMake(0, 0, CoverOrderWidth, CoverOrderWidth);
                oneBT.imageView.contentMode = UIViewContentModeLeft;
                oneBT.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                //oneBT.backgroundColor = UIColor.redColor;
                
                [oneBT setImage:nil forState:UIControlStateHighlighted];
                
                [oneBT addTarget:self action:@selector(orderAction) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
                
            default:
                break;
        }
        
    }
    
    // 设置 orderBT 图片
    [self.orderBT setImage:LmImageThemeBlue1(McPlayOrderImageArray[self.configShare.config.playOrder]) forState:UIControlStateNormal];
    
    self.coverBT = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.contentMode = UIViewContentModeScaleAspectFill;
        button.frame = CGRectMake(0, 0, CoverOrderWidth, CoverOrderWidth);
        
        button.layer.cornerRadius = 6;
        button.layer.borderColor = PRGBF(0, 0, 0, 0.08).CGColor;
        button.layer.borderWidth = 0.5;
        button.clipsToBounds = YES;
        
        [button setImage:[MusicPlayTool share].defaultCoverImage forState:UIControlStateNormal];
        [self addSubview:button];
        
        [button addTarget:self action:@selector(showBigIVAction) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    });
    {
        self.lineView = [UIView new];
        self.lineView.backgroundColor = App_colorSeparator;
        
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
    
    self.rewindBT.hidden = YES;
    self.forwardBT.hidden = YES;
    [self.songInfoL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.slider.bottom +10);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(-15);
    }];
    
    [self.coverBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(self.songInfoL.mas_bottom).mas_offset(7);
        make.size.mas_equalTo(self.coverBT.size);
    }];
    
    [self.playBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.playBT.size);
        
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(self.coverBT.mas_centerY);
    }];
    
    // 顺序
    [self.orderBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.orderBT.size);
        
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self.coverBT.mas_centerY);
    }];
    
#if TARGET_OS_MACCATALYST
    [self.previousBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.previousBT.size);
        
        make.left.mas_greaterThanOrEqualTo(self.coverBT.mas_right);
        make.right.mas_lessThanOrEqualTo(self.playBT.mas_left).mas_offset(-20);
        make.centerY.mas_equalTo(self.coverBT.mas_centerY);
    }];
    
    [self.nextBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.nextBT.size);
        
        make.left.mas_equalTo(self.playBT.mas_right).mas_offset(20);
        make.right.mas_lessThanOrEqualTo(self.orderBT.mas_left);
        make.centerY.mas_equalTo(self.coverBT.mas_centerY);
    }];
#else
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.previousBT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(self.previousBT.size);
            
            make.right.mas_equalTo(self.playBT.mas_left).mas_offset(-40);
            make.centerY.mas_equalTo(self.coverBT.mas_centerY);
        }];
        
        [self.nextBT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(self.nextBT.size);
            
            make.left.mas_equalTo(self.playBT.mas_right).mas_offset(40);
            make.centerY.mas_equalTo(self.coverBT.mas_centerY);
        }];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGFloat x = (self.playBT.left -self.coverBT.right +self.playBT.width)/2;
            
            [self.previousBT mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(self.previousBT.size);
                
                make.centerX.mas_offset(-x);
                make.centerY.mas_equalTo(self.coverBT.mas_centerY);
            }];
            
            [self.nextBT mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(self.nextBT.size);
                
                make.centerX.mas_offset(x);
                make.centerY.mas_equalTo(self.coverBT.mas_centerY);
            }];
        });
    }
#endif
    
    
    
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

- (void)playSongArray:(NSMutableArray<FileEntity> *)itemArray
                   at:(NSInteger)index
             autoPlay:(BOOL)autoPlay

           playFileID:(NSString *)fileId
            searchKey:(NSString * _Nullable)searchKey
{
    if (itemArray.count <= 0) {
        return;
    }
    
    BOOL needRecordPlayHistoryAtFront = NO;
    
    // 用于判断是否需要更新列表
    NSString * arrayDesOld = [self playArrayDes:self.mplShare.currentTempList];
    NSString * arrayDesNew = [self playArrayDes:itemArray];
    
    if (![arrayDesOld isEqualToString:arrayDesNew]) {
        [self.mplShare.currentTempList removeAllObjects];
        [self.mplShare.currentTempList addObjectsFromArray:itemArray];
        
        self.weakLastPlayArray = itemArray;
        needRecordPlayHistoryAtFront = NO;
        
        [self.playHistoryArray removeAllObjects];
        self.playHistoryIndex = 0;
        
        //NSLog(@"itemArray: %p", itemArray);
    } else {
        // 不需要重置播放数组和记忆数组
        // 不需要重置播放历史数组和index
        
    }
    
    //NSLogInteger(index);
    self.configShare.config.currentPlayIndexRow = index;
    
    self.mplShare.currentWeakList = self.mplShare.currentTempList;
    self.playBT.selected = autoPlay;
    
    self.currentItem = self.mplShare.currentWeakList[index];
    [self playItem:self.currentItem autoPlay:autoPlay];
    
    // 更新播放历史
    [self recordPlayHistory:self.currentItem atFront:needRecordPlayHistoryAtFront];
    
    self.configShare.config.playFileID    = fileId;
    self.configShare.config.playSearchKey = searchKey;
}

- (NSString *)playArrayDes:(NSMutableArray<FileEntity> *)array {
    NSMutableString * text = [NSMutableString new];
    for (FileEntity * fe in array) {
        [text appendString:fe.fileNameDeleteExtension];
    }
    return text;
}

- (void)playBTEvent {
    FeedbackShakePhone
    if (self.mpt.audioPlayer.isPlaying) {
        [self pauseEvent];
    }else{
        [self playEvent];
    }
}

- (void)playEvent {
    if (self.mplShare.currentWeakList.count>0) {
        if (!self.currentItem) {
            self.currentItem = self.mplShare.currentWeakList[0];
        }
        [self playItem:self.currentItem autoPlay:YES];
    }
    self.playBT.selected = YES;
}

- (void)pauseEvent {
    [self.mpt pauseEvent];
    self.playBT.selected = NO;
}

- (void)previousBTEvent {
    FeedbackShakePhone
    
    if (self.mplShare.currentWeakList.count>0) {
        NSInteger index = -1;
        BOOL needUpdateHistory = NO;
        // 假如是随机的话, 要检查当前顺序
        if (self.configShare.config.playOrder == McPlayOrderRandom && self.playHistoryArray.count>0) {
            self.playHistoryIndex--;
            if (self.playHistoryIndex >= 0) { // 只有当大于-1的时候, 才会处理播放历史, 否则还是播放其他的
                FileEntity * fe = self.playHistoryArray[self.playHistoryIndex];
                index = [self.mplShare.currentTempList indexOfObject:fe];
            }
        }
        if (index == -1) {
            index = [self getPreviousIndex];
            self.configShare.config.currentPlayIndexRow = index;
            needUpdateHistory = YES;
        } else {
            self.configShare.config.currentPlayIndexRow = index;
        }
        
        self.currentItem = self.mplShare.currentWeakList[index];
        [self playItem:self.currentItem autoPlay:YES];
        
        self.playBT.selected = YES;
        
        if (needUpdateHistory) {
            [self recordPlayHistory:self.currentItem atFront:YES];
        }
    }
}

- (void)nextBTEvent {
    FeedbackShakePhone
    
    if (self.mplShare.currentWeakList.count>0) {
        NSInteger index = -1;
        
        // 随机播放, 当播放历史没有到头, 则播放历史记录.
        BOOL needUpdateHistory = NO;
        if (self.configShare.config.playOrder == McPlayOrderRandom &&  self.playHistoryArray.count>0) {
            self.playHistoryIndex++;
            if (self.playHistoryIndex < self.playHistoryArray.count) {
                FileEntity * fe = self.playHistoryArray[self.playHistoryIndex];
                index = [self.mplShare.currentTempList indexOfObject:fe];
            }
        }
        if (index == -1) {
            index = [self getNextIndex];
            self.configShare.config.currentPlayIndexRow = index;
            needUpdateHistory = YES;
        } else {
            self.configShare.config.currentPlayIndexRow = index;
        }
        
        self.currentItem = self.mplShare.currentWeakList[index];
        [self playItem:self.currentItem autoPlay:YES];
        
        self.playBT.selected = YES;
        
        if (needUpdateHistory) {
            [self recordPlayHistory:self.currentItem atFront:NO];
        }
    }
}

- (NSInteger)getNextIndex {
    NSInteger index = 0;
    switch (self.configShare.config.playOrder) {
        case McPlayOrderRandom:{
            if (self.playHistoryIndex < self.playHistoryArray.count) {
                return self.playHistoryIndex;
            } else {
                index = [self randomNumber];
            }
            break;
        }
        case McPlayOrderNormal:
        case McPlayOrderSingle:
        default:{
            if (self.currentItem) {
                index = [self.mplShare.currentWeakList indexOfObject:self.currentItem] + 1;
            }
            index =  index % self.mplShare.currentWeakList.count;
            break;
        }
    }
    
    return index;
}

- (NSInteger)getPreviousIndex {
    NSInteger index = 0;
    switch (self.configShare.config.playOrder) {
        case McPlayOrderRandom:{
            index = [self randomNumber];
            break;
        }
        case McPlayOrderNormal:
        case McPlayOrderSingle:
        default:{
            if (self.currentItem) {
                index = [self.mplShare.currentWeakList indexOfObject:self.currentItem] - 1;
            }
            index =  index % self.mplShare.currentWeakList.count;
            break;
        }
    }
    
    return index;
}


- (NSInteger)randomNumber {
    NSInteger index = arc4random() % self.mplShare.currentWeakList.count;
    if (index == self.configShare.config.currentPlayIndexRow && self.mplShare.currentWeakList.count>1) {
        return [self randomNumber];
    } else {
        return index;
    }
}

- (void)rewindBTEvent {
    
}

- (void)forwardBTEvent {
    
}

- (void)orderAction {
    FeedbackShakePhone
    
    self.configShare.config.playOrder = (self.configShare.config.playOrder + 1)%McPlayOrderImageArray.count;
    
    [self.orderBT setImage:LmImageThemeBlue1(McPlayOrderImageArray[self.configShare.config.playOrder]) forState:UIControlStateNormal];
}

- (void)playItem:(FileEntity *)item autoPlay:(BOOL)autoPlay {
    
    __block BOOL playSuccess = NO;
    [self.mpt playItem:self.currentItem autoPlay:autoPlay finish:^(NSError * _Nonnull error) {
        playSuccess = error == nil ? YES:NO;
    }];
    
    if (playSuccess) {
        // NSLogString(item.fileName);
        
        self.configShare.config.playFilePath = item.filePath;
        self.configShare.config.playFileNameDeleteExtension = item.fileNameDeleteExtension;
        
        // 刷新SongListDetailVC
        if (self.mpt.nextMusicBlock_rootVC) {
            self.mpt.nextMusicBlock_rootVC();
        }
        if (self.mpt.nextMusicBlock_detailVC) {
            self.mpt.nextMusicBlock_detailVC();
        }
    } else {
        self.configShare.config.playFilePath = @"";
        self.configShare.config.playFileNameDeleteExtension = @"";
        
        if (![item.folderName isEqualToString:ErrorFolderName]) {
            NSString * originPath = [NSString stringWithFormat:@"%@/%@", FT_docPath, item.filePath];
            NSString * errorPath  = [NSString stringWithFormat:@"%@/%@", [MusicFolderEntity errorFolderPath],    item.fileName];
            
            if ([NSFileManager isFileExist:errorPath]) {
                [NSFileManager deleteFile:errorPath];
            }
            [NSFileManager moveFile:originPath to:errorPath];
            
            // 刷新rootData
            [MGJRouter openURL:MUrl_freshFileData];
        } else {
            AlertToastTitle(@"无法播放音乐");
        }
        // 自己的歌单清空
        [self.mplShare.currentTempList removeObject:item];
        
        if (self.mplShare.currentTempList.count > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self nextBTEvent];
            });
        } else {
            AlertToastTitle(@"歌单中无可用文件");
        }
    }
   
}

#pragma mark - 添加随机播放历史
- (void)recordPlayHistory:(FileEntity *)item atFront:(BOOL)atFront {
    if (self.configShare.config.playOrder == McPlayOrderRandom) {
        if (atFront) {
            [self.playHistoryArray insertObject:item atIndex:0];
            self.playHistoryIndex = 0;
        } else {
            [self.playHistoryArray addObject:item];
            self.playHistoryIndex = self.playHistoryArray.count-1;
        }
    }
}

- (void)updateLyricKugou {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.lastMusicTitle isEqualToString:self.currentItem.songName] && self.musicLyricDic) {
            return;
        }
        self.musicLyricDic   = nil;
        self.musicLyricArray = nil;
        self.lastMusicTitle  = self.currentItem.songName;
        
        // 先排查是否有保存
        NSString * lrcPath = [LrcTool lycPath:self.currentItem.fileNameDeleteExtension];
        NSData   * lrcData = [NSData dataWithContentsOfFile:lrcPath];
        if (lrcData) {
            NSString * lrc = [[NSString alloc] initWithData:lrcData encoding:NSUTF8StringEncoding];
            [self parseLrc_1vs1:lrc];
        } else {
            [self requestLrcKugou];
        }
        
    });
}

- (void)requestLrcKugou {
    @weakify(self);
    [LrcKuGou getLrcList:self.currentItem finish:^(LrcKugouListEntity * _Nullable listEntity) {
        @strongify(self);
        if (listEntity.lrcArray.count > 0) {
            LrcKugouListUnitEntity * ue = listEntity.lrcArray.firstObject;
            [LrcKuGou getLrcDetail:self.currentItem id:ue.id accesskey:ue.accesskey finish:^(NSString *string) {
                @strongify(self);
                [self parseLrc_1vs1:string];
            }];
        } else {
            [MGJRouter openURL:MUrl_updateLrcData];
        }
    }];
}

- (void)parseLrc_1vs1:(NSString *)lrc {
    [LrcTool parselrc_1vs1:lrc finish:^(NSMutableDictionary * _Nonnull musicDic, NSMutableArray<LrcDetailEntity *> * _Nonnull musicArray) {
        self.musicLyricDic   = musicDic;
        self.musicLyricArray = musicArray;
        
        NSDictionary * dic = @{@"lrcArray":self.musicLyricArray};
        [MGJRouter openURL:MUrl_updateLrcData withUserInfo:dic completion:nil];
    }];
}

- (void)showBigIVAction {
    FeedbackShakePhone
    
    [MGJRouter openURL:MUrl_showLrc];
    
    self.songInfoL.text = self.mpt.musicItem.fileNameDeleteExtension;
}

@end

