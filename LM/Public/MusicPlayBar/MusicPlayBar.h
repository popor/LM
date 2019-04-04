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

#define MpbShare [MusicPlayBar share]

NS_ASSUME_NONNULL_BEGIN

@interface MusicPlayBar : UIView

+ (MusicPlayBar *)share;

@property (nonatomic, strong) UIView  * lineView;
@property (nonatomic, strong) UILabel * nameL;
@property (nonatomic, strong) UILabel * timeCurrentL;
@property (nonatomic, strong) UILabel * timeDurationL;

@property (nonatomic, strong) UIButton * orderBT;

//@property (nonatomic, strong) MusicSlider * slider;
@property (nonatomic, strong) UISlider * slider;


@property (nonatomic, strong) UIImageView * coverIV;
@property (nonatomic, strong) UIButton * playBT;
@property (nonatomic, strong) UIButton * previousBT;
@property (nonatomic, strong) UIButton * nextBT;
@property (nonatomic, strong) UIButton * rewindBT;
@property (nonatomic, strong) UIButton * forwardBT;

@property (nonatomic, weak  ) MusicPlayTool       * mpt;
@property (nonatomic, weak  ) MusicPlayListTool   * mplt;

@property (nonatomic, weak  ) MusicPlayItemEntity * currentItem;

// 播放临时数组
- (void)playTempArray:(NSArray *)itemArray at:(NSInteger)index;

// 播放歌单列表
- (void)playRecordArray:(NSMutableArray *)itemArray at:(NSInteger)index;

- (void)playEvent;
- (void)pauseEvent;

- (void)previousBTEvent;
- (void)nextBTEvent;
- (void)rewindBTEvent;
- (void)forwardBTEvent;

@end

NS_ASSUME_NONNULL_END
