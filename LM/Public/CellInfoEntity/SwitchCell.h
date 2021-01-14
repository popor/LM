//
//  SwitchCell.h
//  linRunShengPi
//
//  Created by apple on 2018/3/23.
//  Copyright © 2018年 popor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchCell : UITableViewCell

@property (nonatomic, strong) UISwitch * uis;

@property (nonatomic, copy  ) void (^switchBlock)(UISwitch * uis);

@end
