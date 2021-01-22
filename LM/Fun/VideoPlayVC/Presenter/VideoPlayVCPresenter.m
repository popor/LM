//
//  VideoPlayVCPresenter.m
//  hywj
//
//  Created by popor on 2020/12/15.
//  Copyright © 2020 popor. All rights reserved.

#import "VideoPlayVCPresenter.h"
#import "VideoPlayVCInteractor.h"

#import "UIViewController+pAutorotate.h"

//#import <SDWebImage/SDWebImage.h>
//#import <PoporSDWebImage/UIImageView+PoporSDWebImage.h>


@interface VideoPlayVCPresenter ()

@property (nonatomic, weak  ) id<VideoPlayVCProtocol> view;
@property (nonatomic, strong) VideoPlayVCInteractor * interactor;

@property (nonatomic, copy  ) NSString * currentPlayVideoId;


@end

@implementation VideoPlayVCPresenter

- (void)dealloc {
    PoporAvPlayerRecord * record = [PoporAvPlayerRecord share];
    
    [record stopEvent];
    [record recordEvent];
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)setMyInteractor:(VideoPlayVCInteractor *)interactor {
    self.interactor = interactor;
    
}

- (void)setMyView:(id<VideoPlayVCProtocol>)view {
    self.view = view;
    
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    [self play];
}

//@protocol JPVideoPlayerControlBar_popor <NSObject>
- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView landscapeBT:(UIButton *)button {
    button.selected = !button.isSelected;
    if (button.isSelected) {
        [self.view videoLandscapeOrientation];
    } else {
        [self.view videoPortraintOrientation];
    }
}

- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView playBT:(UIButton *)button {
    if ([poporAvPlayerView.bottomBar isPlayBTStatus_playing]) {
        [self.view.videoPlayView pausePlay];
        [self.view.record pauseEvent];
    } else {
        [self.view.videoPlayView startPlay];
        [self.view.record playEvent];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.view.videoPlayView setRate:self.interactor.playVideoRate];
        });
    }
}

- (void)play {
    VideoPlayEntity * entity = self.view.videoInfoArray.firstObject;
    NSURL * url = [NSURL fileURLWithPath:entity.videoUrl];
    [self.view.videoPlayView playVideoUrl:url seekTime:0];
    [self.view.videoPlayView setRate:self.interactor.playVideoRate];
    self.view.videoPlayView.topBar.titleL.text = entity.videoName;
}

- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView previousBT:(UIButton *)button { }

- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView nextBT:(UIButton *)button { }

- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView rateBT:(UIButton *)button {
    self.view.videoConfigTvView.weakEntityArray = self.interactor.rateArray;
    if (PSCREEN_SIZE.width < PSCREEN_SIZE.height) {
        self.view.videoConfigTvView.cellH = 40;
        [self.view.videoConfigTvView showAtView:self.view.videoPlayView tvWidth:140];
    } else {
        self.view.videoConfigTvView.cellH = 60;
        [self.view.videoConfigTvView showAtView:self.view.videoPlayView tvWidth:180];
    }
}

- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView definitionBT:(UIButton *)button {
    if (self.view.videoInfoArray.count == 0) {
        AlertToastTitle(@"暂无可用视频播放");
    } else {
        self.view.videoConfigTvView.weakEntityArray = self.view.videoInfoArray;
        if (PSCREEN_SIZE.width < PSCREEN_SIZE.height) {
            self.view.videoConfigTvView.cellH = 40;
            [self.view.videoConfigTvView showAtView:self.view.videoPlayView tvWidth:140];
        } else {
            self.view.videoConfigTvView.cellH = 60;
            [self.view.videoConfigTvView showAtView:self.view.videoPlayView tvWidth:180];
        }
    }
}

- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView videoNumBT:(UIButton *)button {
    
}

- (BOOL)poporAvPlayerViewCheckNetPermission:(PoporAvPlayerView *)poporAvPlayerView {
    return YES;
    // 本地播放器, 不需要检查网络
    //    AFNetworkReachabilityManager * afnSM = [AFNetworkReachabilityManager sharedManager];
    //    NetPermissionEntityTool * tool       = [NetPermissionEntityTool share];
    //    if (afnSM.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN && !tool.npEntity.allowMobileViewMp4) {
    //        
    //        UIAlertController * oneAC = [UIAlertController alertControllerWithTitle:nil message:@"您正在使用非wifi网络播放，会产生额外流量，是否继续" preferredStyle:UIAlertControllerStyleAlert];
    //        
    //        UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    //        
    //        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //            [MGJRouter openURL:MUrl_mineAppSet];
    //        }];
    //        
    //        [oneAC addAction:cancleAction];
    //        [oneAC addAction:okAction];
    //        
    //        [self.view.vc presentViewController:oneAC animated:YES completion:nil];
    //        return NO;
    //    } else {
    //        return YES;
    //    }
}

#pragma mark - VideoConfigTvView Delegate
// 默认只有一个 section
- (NSInteger)videoConfigTvViewCount:(VideoConfigTvView *)configView {
    return configView.weakEntityArray.count;
}

- (void)videoConfigTvView:(VideoConfigTvView *)configView indexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell {
    BOOL select = NO;
    if (configView.weakEntityArray == self.interactor.rateArray) {
        VideoRateEntity * entity = self.interactor.rateArray[indexPath.row];
        cell.textLabel.text = entity.title;
        cell.detailTextLabel.text = nil;
        
        select = self.interactor.playVideoRate == entity.value;
    }
    
    else if (configView.weakEntityArray == self.view.videoInfoArray) {
        VideoPlayEntity * entity = self.view.videoInfoArray[indexPath.row];
        cell.textLabel.text = entity.videoDefinitionText;
        cell.detailTextLabel.text = nil;
        
        select = [entity.videoDefinitionText isEqualToString:self.interactor.definateText];
    }
    
//    else if (configView.weakEntityArray == self.interactor.videoArray) {
//        LearnCourseInfoUnityEntity * entity = self.interactor.videoArray[indexPath.row];
//        cell.textLabel.text = entity.periodName;
//        cell.detailTextLabel.text = entity.videoSecondStr;
//
//        select = [entity.periodName isEqualToString:self.interactor.videoNameText];
//    }
    
    if (select) {
        cell.textLabel.textColor = App_colorTheme;
        cell.detailTextLabel.textColor = App_colorTheme;
    } else {
        cell.textLabel.textColor = PColorWhite;
        cell.detailTextLabel.textColor = PColorWhite;
    }
}

- (void)videoConfigTvView:(VideoConfigTvView *)configView selectIndex:(NSInteger)indexRow {
    if (configView.weakEntityArray == self.interactor.rateArray) {
        VideoRateEntity * entity = self.interactor.rateArray[indexRow];
        //configView.selectString = entity.title;
        self.interactor.playVideoRate = entity.value;
        
        [self.view.videoPlayView setRate:self.interactor.playVideoRate];
    }
    
    else if (configView.weakEntityArray == self.view.videoInfoArray) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            VideoPlayEntity * entity = self.view.videoInfoArray[indexRow];
            NSString * url  = entity.videoUrl ? : @"";
            NSString * type = entity.videoDefinitionText ? : @"高清";
            
            [self playVideoUrl:url];
            [self.view.videoPlayView.bottomBar.definitionBT setTitle:type forState:UIControlStateNormal];
            
            [self.view.videoPlayView showControlBar];
            //self.view.videoPlayView.topBar.titleL.text = self.interactor.mp4PlayCourseUE.periodName; // 预设标题名称
            
            self.interactor.definateText = type;
            //self.interactor.videoNameText = self.interactor.mp4PlayCourseUE.periodName;
        });
        
    }
    
    //    else if (configView.weakEntityArray == self.interactor.videoArray) {
    //        LearnCourseInfoUnityEntity * ue = self.interactor.videoArray[indexRow];
    //        [self playMp4CourseUE:ue];
    //    }
}

- (void)playVideoUrl:(NSString *)videoUrl {
    NSLog(@"videoUrl: %@", videoUrl);
    NSInteger videoPlayTime = self.view.record.elapsedSeconds;
    [self.view.videoPlayView playVideoUrl:[NSURL URLWithString:videoUrl] seekTime:videoPlayTime];
    [self.view.videoPlayView setRate:self.interactor.playVideoRate];
}

//@protocol JPVideoPlayerControlTopBar_popor <NSObject>
- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView topRightBT:(UIButton *)button {

}

- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView topCustomBT:(UIButton *)button {
    [self downloadShareFavEtcBtAction:button];
}

- (void)downloadShareFavEtcBtAction:(UIButton *)button {
    if (button == self.view.avDownloadBT) {
       
    } else if(button == self.view.avShareBT || button == self.view.coverShareBT) {
        
    } else if(button == self.view.avFavBT || button == self.view.coverFavBT) {
        
    }
}

- (void)poporAvPlayerView:(PoporAvPlayerView *)poporAvPlayerView backBT:(UIButton *)button {
    if (PSCREEN_SIZE.width != PScreenWidth) {
        [self.view videoPortraintOrientation];
    } else {
        [self.view.vc.navigationController popViewControllerAnimated:YES];
    }
}

// 是否自动重复播放
- (BOOL)shouldAutoReplayForURL:(nonnull NSURL *)videoURL {
    return NO;
}

- (void)playAtTime:(NSInteger)playTime {
    [self.view.videoPlayView setPlayTime:playTime];
    [self.view.videoPlayView setRate:self.interactor.playVideoRate];
}

#pragma mark - Interactor_EventHandler


@end
