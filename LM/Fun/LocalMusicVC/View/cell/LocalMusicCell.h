//
//  LocalMusicCell.h
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.
//

#import <UIKit/UIKit.h>

static int LocalMusicCellH = 50;

NS_ASSUME_NONNULL_BEGIN

@interface LocalMusicCell : UITableViewCell

@property (nonatomic, weak  ) id cellData;

@property (nonatomic, strong) UIButton * addBt;
@property (nonatomic, strong) UILabel  * titelL;
@property (nonatomic, strong) UILabel  * timeL;
@property (nonatomic, strong) UIButton * rightIV;

@end

NS_ASSUME_NONNULL_END
