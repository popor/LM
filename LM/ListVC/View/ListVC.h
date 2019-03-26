//
//  ListVC.h
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "ListVCProtocol.h"

@interface ListVC : UIViewController <ListVCProtocol>

- (instancetype)initWithDic:(NSDictionary *)dic;

@end
