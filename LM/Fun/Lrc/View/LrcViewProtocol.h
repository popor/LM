//
//  LrcViewProtocol.h
//  LM
//
//  Created by popor on 2020/10/14.
//  Copyright © 2020 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "LrcDetailEntity.h"
#import "AlertWindowImageView.h"
#import "FeedbackGeneratorTool.h"

NS_ASSUME_NONNULL_BEGIN

#define KDragColor PRGBF(234,111,59, 1) //UIColor.orangeColor
static CGFloat LrcViewTvCellDefaultH = 40;

// MARK: 对外接口
@protocol LrcViewProtocol <NSObject>

- (UIView *)view;
- (void)updateInfoTVContentInset;

// MARK: 自己的
// 图片缩放
@property (nonatomic, strong) UIScrollView * coverSV;
@property (nonatomic, strong) UIImageView  * coverIV;

@property (nonatomic        ) BOOL          tvDrag;
@property (nonatomic, strong) UITableView * infoTV;
@property (nonatomic, strong) UIButton    * closeBT;
@property (nonatomic, getter=isShow) BOOL   show;

@property (nonatomic, strong) UIButton    * coverFillBT;
@property (nonatomic, strong) UIButton    * coverCloseBT;

@property (nonatomic, strong) UIView        * dragLrcTimeView;
@property (nonatomic, strong) UIImageView   * lineView1;
@property (nonatomic, strong) UIImageView   * lineView2;

@property (nonatomic, strong) UILabel  * timeL;
@property (nonatomic, strong) UIButton * playBT;
@property (nonatomic, strong) UITapGestureRecognizer * coverLrcTapGR; // 封面和歌词切换GR
@property (nonatomic, strong) UITapGestureRecognizer * dragLrcTapGR; // 拖拽歌词后点击GR

// MARK: 外部注入的

@end

// MARK: 数据来源
@protocol LrcViewDataSource <NSObject>

@end

// MARK: UI事件
@protocol LrcViewEventHandler <NSObject>

- (void)updateLrcArray:(NSArray *)array;
- (void)scrollToLrc:(LrcDetailEntity *)lrc;
- (void)scrollToTopIfNeed;

- (void)endDragDelay;

- (void)playBTAction:(UITapGestureRecognizer *)tapGR;

@end

NS_ASSUME_NONNULL_END
