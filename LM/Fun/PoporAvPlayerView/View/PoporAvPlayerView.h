//
//  PoporAvPlayerView.h
//  hywj
//
//  Created by popor on 2020/9/5.
//  Copyright © 2020 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "PoporAvPlayerViewProtocol.h"

@interface PoporAvPlayerView : UIView <PoporAvPlayerViewProtocol>

@property (nonatomic, strong) UIImageView *blurImageView;

- (instancetype)initWithDic:(NSDictionary *)dic;

- (void)assembleViper;

- (void)addViews;

@end
