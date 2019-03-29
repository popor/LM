//
//  WifiAddFileVC.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "WifiAddFileVCProtocol.h"

@interface WifiAddFileVC : UIViewController <WifiAddFileVCProtocol>

- (instancetype)initWithDic:(NSDictionary *)dic;

@end
