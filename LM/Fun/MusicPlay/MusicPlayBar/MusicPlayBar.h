//
//  MusicPlayBar.h
//  LM
//
//  Created by apple on 2019/3/28.
//  Copyright © 2019 popor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MusicPlayListTool.h"
#import "MusicPlayTool.h"
#import "LrcDetailEntity.h"

#define MpbShare [MusicPlayBar share]

NS_ASSUME_NONNULL_BEGIN

@interface MusicPlayBar : UIView

+ (MusicPlayBar *)share;

@property (nonatomic, weak  ) UINavigationController * rootNC;

@property (nonatomic, strong) UIView  * lineView;
@property (nonatomic, strong) UILabel * songInfoL;
@property (nonatomic, strong) UILabel * timeCurrentL;
@property (nonatomic, strong) UILabel * timeDurationL;

@property (nonatomic, strong) UIButton * orderBT;

//@property (nonatomic, strong) MusicSlider * slider;
@property (nonatomic, strong) UISlider * slider;
@property (nonatomic, getter=isSliderSelected) BOOL sliderSelected;
@property (nonatomic, strong) UILabel  * sliderTimeL;

@property (nonatomic, strong) UIButton * coverBT;
@property (nonatomic, strong) UIButton * playBT;
@property (nonatomic, strong) UIButton * previousBT;
@property (nonatomic, strong) UIButton * nextBT;
@property (nonatomic, strong) UIButton * rewindBT;
@property (nonatomic, strong) UIButton * forwardBT;

//@property (nonatomic, strong) UIButton * exitPlaySearchLocalBT; //退出播放搜索结果模式

@property (nonatomic, weak  ) MusicPlayTool       * mpt;
@property (nonatomic, weak  ) MusicPlayListTool   * mplt;

@property (nonatomic, weak  ) FileEntity * currentItem;

@property (nonatomic, copy  ) NSMutableDictionary * _Nullable musicLyricDic;
@property (nonatomic, copy  ) NSArray * _Nullable musicLyricArray;
@property (nonatomic, getter=isShowLrc) BOOL showLrc;

// 只针对于随机模式
@property (nonatomic, strong) NSMutableArray<FileEntity> * playHistoryArray;
@property (nonatomic        ) NSInteger                    playHistoryIndex;

// 用于记录上次播放的列表地址
@property (nonatomic, weak  ) NSMutableArray<FileEntity> * _Nullable weakLastPlayArray;
//明天处理逻辑.
//退出该页面或者点击了完成,就退出搜索结果?
//当在播放搜索音乐的时候,每次播放下一首,就刷新当前页面歌单config?

// 是否在播放搜索或本地音乐.
@property (nonatomic, getter=isPlaySearchLocalItem) BOOL playSearchLocalItem;

// 播放临时数组
//- (void)playSongArray:(NSMutableArray<FileEntity> *)itemArray folder:(NSString * _Nullable)folderName at:(NSInteger)index autoPlay:(BOOL)autoPlay;

- (void)playSongArray:(NSMutableArray<FileEntity> *)itemArray
                   at:(NSInteger)index
             autoPlay:(BOOL)autoPlay

           playFileID:(NSString *)fileId
            searchKey:(NSString * _Nullable)searchKey
;
             

- (void)playEvent;
- (void)pauseEvent;

- (void)previousBTEvent;
- (void)nextBTEvent;
- (void)rewindBTEvent;
- (void)forwardBTEvent;

- (void)updateTimeCurrentFrameTime:(CGFloat)widthTag;

- (void)updateTimeDurationFrameTime:(CGFloat)widthTag;

- (void)updateProgressSectionFrame;

- (void)updateLyricKugou;

@end

NS_ASSUME_NONNULL_END

