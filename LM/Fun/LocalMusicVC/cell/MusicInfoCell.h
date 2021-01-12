//
//  MusicInfoCell.h
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.
//

#import <UIKit/UIKit.h>

static int MusicInfoCellH = 50;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int, MusicInfoCellType) {
    MusicInfoCellTypeDefault, // 只显示文字
    MusicInfoCellTypeAdd, // 显示Add按钮
    
};

@interface MusicInfoCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(MusicInfoCellType)type;

@property (nonatomic        ) MusicInfoCellType type;

@property (nonatomic, weak  ) id cellData;

@property (nonatomic, strong) UIButton * addBt;
@property (nonatomic, strong) UILabel  * titelL;
@property (nonatomic, strong) UILabel  * subtitleL;
@property (nonatomic, strong) UIImageView * rightIV;

@end

NS_ASSUME_NONNULL_END
