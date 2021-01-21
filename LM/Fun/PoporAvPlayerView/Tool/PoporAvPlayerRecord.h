//
//  PoporAvPlayerRecord.h
//  hywj
//
//  Created by popor on 2020/9/5.
//  Copyright © 2020 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^JPVideoRecordHiddenControlBlock) (BOOL hidden);

@interface PoporAvPlayerRecord : NSObject

@property (nonatomic        ) NSInteger chontrolHiddenTime;
@property (nonatomic        ) BOOL      chontrolHiddenPause;

@property (nonatomic, copy  ) NSURL    * _Nullable videoPlayUrl;

@property (nonatomic, copy  ) NSString * _Nullable videoId; // 回放火录播视频id

@property (nonatomic        ) CGFloat currentTime;
@property (nonatomic        ) CGFloat elapsedSeconds;
@property (nonatomic        ) CGFloat totalSeconds;

@property (nonatomic        ) NSInteger videoIdPlayTime;// 内部使用

//@property (nonatomic, copy  ) BlockPVoid _Nullable preparePlayBlock;

@property (nonatomic, copy  ) JPVideoRecordHiddenControlBlock _Nullable hiddenControlBarBlock;

+ (instancetype)share;

- (void)setDefaultData;

- (void)updateVideoId:(NSString *)videoId;

- (void)playEvent;

- (void)pauseEvent;

- (void)stopEvent;

- (void)recordEvent;

@end

NS_ASSUME_NONNULL_END
