//
//  PoporAvPanGR.h
//  hywj
//
//  Created by popor on 2020/6/14.
//  Copyright © 2020 popor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MPVolumeView.h>
#import "PoporAvPlayerBrightnessView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VideoPlayBackVCPanType) {
    VideoPlayBackVCPanType_seek = 1,
    VideoPlayBackVCPanType_volume,
    VideoPlayBackVCPanType_brightness,
};

@interface PoporAvPanGR : NSObject

@property (nonatomic, strong) UILabel  *seekTimeLable;
@property (nonatomic, strong) UISlider *seekSlider;
@property (nonatomic, strong) MPVolumeView *volumeView;

@property (nonatomic        ) VideoPlayBackVCPanType panType;
@property (nonatomic        ) CGPoint lastPoint;

@property (nonatomic, strong) UIPanGestureRecognizer *panGr; // HY_Edit 转移到h


- (void)showSeekAtView:(UIView *)view;
- (void)hiddenSeek;

- (void)startShowBrightness;

- (void)changeVolume:(CGFloat)distance atView:(UIView *)view;

- (void)changeBrightness:(CGFloat)distance;

+ (NSString *)timeText:(NSTimeInterval)time;

/**
 scale 默认为 300.0
 */
+ (CGFloat)valueOfDistance:(CGFloat)distance baseValue:(CGFloat)baseValue scale:(CGFloat)scale;



@end

NS_ASSUME_NONNULL_END
