//
//  SongListDetailVC.h
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "SongListDetailVCProtocol.h"

@interface SongListDetailVC : UIViewController <SongListDetailVCProtocol>

- (instancetype)initWithDic:(NSDictionary *)dic;

@end
