//
//  LocalMusicVC.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "LocalMusicVCProtocol.h"

@interface LocalMusicVC : UIViewController <LocalMusicVCProtocol>

- (instancetype)initWithDic:(NSDictionary *)dic;

@end
