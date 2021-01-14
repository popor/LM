//
//  SwitchCell.m
//  linRunShengPi
//
//  Created by apple on 2018/3/23.
//  Copyright © 2018年 popor. All rights reserved.
//

#import "SwitchCell.h"

@implementation SwitchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        if (!self.uis) {
            self.accessoryView = ({
                UISwitch * uis = [UISwitch new];
                uis.onTintColor = App_colorTheme;
                [uis addTarget:self action:@selector(uisAction) forControlEvents:UIControlEventValueChanged];
                uis;
            });
            self.uis = (UISwitch *)self.accessoryView;
        }
    }
    return self;
}

- (void)uisAction {
    if (self.switchBlock) {
        self.switchBlock(self.uis);
    }
}

@end
