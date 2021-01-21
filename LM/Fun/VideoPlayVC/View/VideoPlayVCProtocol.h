//
//  VideoPlayVCProtocol.h
//  hywj
//
//  Created by popor on 2020/12/15.
//  Copyright © 2020 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import "PoporAvPlayerView.h"
#import "PoporAvPlayerRecord.h"

#import "PoporAvPanGR.h"
#import "VideoConfigTvView.h"

#import "VideoPlayEntity.h"

@class LearnMp4VideoUnitEntity;

NS_ASSUME_NONNULL_BEGIN

// MARK: 对外接口
@protocol VideoPlayVCProtocol <NSObject>

- (UIViewController *)vc;

- (void)videoPortraint;
- (void)videoLandscape;

- (void)videoPortraintOrientation;
- (void)videoLandscapeOrientation;

// MARK: 自己的
@property (nonatomic, strong) PoporAvPlayerView * videoPlayView;
@property (nonatomic, weak  ) PoporAvPlayerRecord * record;

// 自定义模块
@property (nonatomic, strong) VideoConfigTvView * videoConfigTvView;
@property (nonatomic, getter=isDevicePortraint) BOOL devicePortraint;

// 开始使用自定义的视频播放器头部按钮
@property (nonatomic, strong) UIButton * avDownloadBT;
@property (nonatomic, strong) UIButton * avFavBT;     // 视频控制器上的
@property (nonatomic, strong) UIButton * avShareBT;   // 视频控制器上的

@property (nonatomic, strong) UIButton * coverFavBT;  // 蒙层控制器上的
@property (nonatomic, strong) UIButton * coverShareBT;// 蒙层控制器上的

@property (nonatomic, strong) UIImageView * shareIV; // 预先下载分享图片

// MARK: 外部注入的
@property (nonatomic, strong) NSMutableArray<VideoPlayEntity *> * videoInfoArray;

@end

// MARK: 数据来源
@protocol VideoPlayVCDataSource <NSObject>

@end

// MARK: UI事件
@protocol VideoPlayVCEventHandler <NSObject>

@end

NS_ASSUME_NONNULL_END
