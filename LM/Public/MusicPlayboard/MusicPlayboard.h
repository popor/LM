//
//  MusicPlayboard.h
//  LM
//
//  Created by apple on 2019/3/28.
//  Copyright © 2019 popor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <StepSlider/StepSlider.h>

NS_ASSUME_NONNULL_BEGIN

//- (void)playBTEvent;
//- (void)previousBTEvent;
//- (void)nextBTEvent;
//- (void)rewindBTEvent;
//- (void)forwardBTEvent;

@interface MusicPlayboard : UIView

+ (MusicPlayboard *)share;

@property (nonatomic, strong) UILabel * nameL;
@property (nonatomic, strong) UILabel * timeL;
@property (nonatomic, strong) UIButton * orderBT;

@property (nonatomic, strong) StepSlider * slider;

@property (nonatomic, strong) UIButton * playBT;
@property (nonatomic, strong) UIButton * previousBT;
@property (nonatomic, strong) UIButton * nextBT;
@property (nonatomic, strong) UIButton * rewindBT;
@property (nonatomic, strong) UIButton * forwardBT;


@end

NS_ASSUME_NONNULL_END
