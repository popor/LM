//
//  PoporAvPanGR.m
//  hywj
//
//  Created by popor on 2020/6/14.
//  Copyright © 2020 popor. All rights reserved.
//

#import "PoporAvPanGR.h"

@implementation PoporAvPanGR

- (id)init {
    if (self = [super init]) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    
    self.seekTimeLable = ({
        UILabel * oneL = [UILabel new];
        oneL.backgroundColor     = [UIColor clearColor]; // ios8 之前
        oneL.font                = [UIFont systemFontOfSize:20];
        oneL.textColor           = [UIColor whiteColor];
        oneL.textAlignment       = NSTextAlignmentCenter;
        oneL.layer.masksToBounds = YES; // ios8 之后 lableLayer 问题
        oneL.numberOfLines       = 1;
        
        oneL.layer.shadowColor   = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5].CGColor;
        oneL.layer.shadowOffset  = CGSizeMake(-0.2, -0.2);
        oneL.layer.shadowRadius  = 0.2;
        oneL.layer.shadowOpacity = 1.0;
        
        oneL;
    });
    
    self.seekSlider = ({
        UISlider * oneS = [[UISlider alloc] init];
        oneS.minimumTrackTintColor = App_colorTheme;
        oneS.maximumTrackTintColor = [UIColor lightGrayColor];
        [oneS setThumbImage:[UIImage imageFromColor:[UIColor whiteColor] size:CGSizeMake(4, 4) corner:2] forState:UIControlStateNormal];
        
        oneS;
    });
    
    self.seekSlider.alpha    = 0;
    self.seekTimeLable.alpha = 0;
}

- (void)showSeekAtView:(UIView *)view {
    
    [view addSubview:self.seekSlider];
    [view addSubview:self.seekTimeLable];
    
    CGFloat width  = 200;
    CGFloat height = 30;
    CGFloat moveY  = 20; // *2
    self.seekSlider.frame    = CGRectMake((view.bounds.size.width - width)/2, view.bounds.size.height/2 - height - moveY,   width, height);
    self.seekTimeLable.frame = CGRectMake(self.seekSlider.frame.origin.x,     CGRectGetMaxY(self.seekSlider.frame),         width, height);
    
    self.seekSlider.alpha    = 0;
    self.seekTimeLable.alpha = 0;
    [UIView animateWithDuration:0.15 animations:^{
        self.seekSlider.alpha    = 1;
        self.seekTimeLable.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hiddenSeek {
    [UIView animateWithDuration:0.15 animations:^{
        self.seekSlider.alpha    = 0;
        self.seekTimeLable.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)changeVolume:(CGFloat)distance atView:(UIView *)view {
    
    if (self.volumeView == nil) {
        self.volumeView = ({
            MPVolumeView * vv = [[MPVolumeView alloc] init];
            vv.showsVolumeSlider = YES;
            [vv sizeToFit];
            vv.hidden = YES;
            
            [view addSubview:vv];
            vv;
        });
       
    }
    
    for (UIView *v in self.volumeView.subviews) {
        if ([v.class.description isEqualToString:@"MPVolumeSlider"]) {
            UISlider *volumeSlider = (UISlider *)v;
            [volumeSlider setValue:[PoporAvPanGR valueOfDistance:distance baseValue:volumeSlider.value scale:0] animated:NO];
            [volumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
            break;
        }
    }
}

- (void)startShowBrightness {
    [PoporAvPlayerBrightnessView sharedBrightnessView];
}

- (void)changeBrightness:(CGFloat)distance {
    [UIScreen mainScreen].brightness = [PoporAvPanGR valueOfDistance:distance baseValue:[UIScreen mainScreen].brightness scale:0];
}

+ (NSString *)timeText:(NSTimeInterval)time {
    NSInteger hour = floor(time / 3600.0);
    CGFloat minute = floor(time / 60.0);
    CGFloat second = fmod(time, 60.0);
    
    if (hour > 0) {
        return [NSString stringWithFormat:@"%li:%02.0f:%02.0f", hour, minute, second];
    } else {
        return [NSString stringWithFormat:@"%02.0f:%02.0f", minute, second];
    }
}

/**
 scale 默认为 300.0
 */
+ (CGFloat)valueOfDistance:(CGFloat)distance baseValue:(CGFloat)baseValue scale:(CGFloat)scale {
    if (scale <= 0) {
        scale = 300.0;
    }
    CGFloat value = baseValue + distance / 300.0f;
    if (value < 0.0) {
        value = 0.0;
    } else if (value > 1.0) {
        value = 1.0;
    }
    return value;
}

@end
