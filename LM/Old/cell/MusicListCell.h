//
//  MusicListCell.h
//  LM
//
//  Created by apple on 2019/4/2.
//  Copyright © 2019 popor. All rights reserved.
//

#import <UIKit/UIKit.h>

static int MusicListCellH = 50;

NS_ASSUME_NONNULL_BEGIN

@interface MusicListCell : UITableViewCell

@property (nonatomic, weak  ) id cellData;

// @property (nonatomic, strong) UIButton * playBt;
@property (nonatomic, strong) UILabel  * titelL;
@property (nonatomic, strong) UIImageView * rightIV;

@end

NS_ASSUME_NONNULL_END
