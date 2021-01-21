//
//  PoporAvPlayerRecord.m
//  hywj
//
//  Created by popor on 2020/9/5.
//  Copyright © 2020 popor. All rights reserved.
//

#import "PoporAvPlayerRecord.h"
//#import "VideoPlayerRecordEntity.h"

static NSInteger MonitorPlayTime = 1;

@interface PoporAvPlayerRecord ()
@property (nonatomic, strong) RACDisposable * timerDispoable;
@property (nonatomic        ) BOOL pauseTimer; // 暂停计时

//@property (nonatomic, copy  ) void (^playBlock)(JPVideoRecord * jpvr);
//
//@property (nonatomic, copy  ) void (^pauseBlock)(JPVideoRecord * jpvr);
//
//@property (nonatomic, copy  ) void (^pauseRecordBlock)(JPVideoRecord * jpvr);

@property (nonatomic, copy  ) NSString * lastSubmitDicString;


@end

@implementation PoporAvPlayerRecord

+ (instancetype)share {
    static dispatch_once_t once;
    static PoporAvPlayerRecord * instance;
    dispatch_once(&once, ^{
        instance = [PoporAvPlayerRecord new];
        
        
    });
    return instance;
}

- (void)setDefaultData {
    
    self.chontrolHiddenTime = 0;
    self.chontrolHiddenPause = NO;
    
    self.videoPlayUrl = nil;
    
    self.videoId = nil;
    
    self.currentTime = 0;
    self.elapsedSeconds = 0;
    self.totalSeconds = 0;
    
    self.videoIdPlayTime = 0;
    
    self.hiddenControlBarBlock = nil;
    
}

- (void)updateVideoId:(NSString *)videoId {
    
    if (![videoId isEqualToString:self.videoId]) {
        [self recordEvent];
        
        if (self.timerDispoable) {
            [self.timerDispoable dispose];
        }
        
        self.videoId         = videoId;
        self.videoIdPlayTime = 0;
        
        @weakify(self);
        
        self.timerDispoable = [[RACSignal interval:MonitorPlayTime onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            @strongify(self);
            
            [self playTimerRecordEvent];
        }];
        
    } else {
        
    }
}

// 计时器
- (void)playTimerRecordEvent {
    if (!self.pauseTimer) {
        self.videoIdPlayTime += MonitorPlayTime;
    }
}

- (void)playEvent {
    self.pauseTimer = NO;
}

- (void)pauseEvent {
    self.pauseTimer = YES;
}

- (void)stopEvent {
    if (self.timerDispoable) {
        [self.timerDispoable dispose];
    }
}

- (void)recordEvent {
    //    if (self.totalSeconds > 0) { // 当视频获取成功之后
    //        [self submitVideoId:self.videoId lookTime:MIN(self.elapsedSeconds, self.totalSeconds) totalTime:self.videoIdPlayTime];
    //        [VideoPlayerRecordEntity updateTime:self.elapsedSeconds videoId:self.videoId];
    //    }
}

//- (void)submitVideoId:(NSString *)videoId lookTime:(NSInteger)lookTime totalTime:(NSInteger)totalTime {
//    if (!self.videoId) {
//        return;
//    }
//    if (ADT.token.access_token.length == 0) {
//        // 未登录的时候不要提交
//        return;
//    }
//    NSDictionary * dic = @{@"videoId":videoId, @"lookTime":@(lookTime), @"totalTime":@(totalTime)};
//    NSString * url     = NetURL(@"courseService/study/progress");
//    NSString * title   = @"视频提交观看记录";
//    // NSLog(@"dic : %@", dic);
//    
//    // 由于每次退出页面都会检查, 所以存在重复提交情况, 所以需要在这里判断下.
//    if (![self.lastSubmitDicString isEqualToString:dic.description]) {
//        self.lastSubmitDicString = dic.description;
//    } else {
//        return;
//    }
//    //    return;
//    [NetService title:title url:url method:PoporMethodFormData parameters:dic success:^(NSString * _Nonnull url, NSData * _Nonnull data, NSDictionary * _Nonnull dic) {
//        //NSLog(@"%@: %@", title, dic.description);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {}];
//    
//    // self.videoId = nil;
//}


@end
