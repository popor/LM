//
//  RootVC.h
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "RootVCProtocol.h"

@interface RootVC : UIViewController <RootVCProtocol>

- (instancetype)initWithDic:(NSDictionary *)dic;

@end
