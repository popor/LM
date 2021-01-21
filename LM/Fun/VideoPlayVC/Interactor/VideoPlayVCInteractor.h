//
//  VideoPlayVCInteractor.h
//  hywj
//
//  Created by popor on 2020/12/15.
//  Copyright © 2020 popor. All rights reserved.

#import <Foundation/Foundation.h>

#import "VideoRateEntity.h"

//#import "LearnCourseInfoEntity.h"
//#import "LearnCoursePdfEntity.h"
//#import "LearnCourseTeacherEntity.h"
//#import "LearnMp4InfoEntity.h"
//
//#import "PlvConfigEntity.h"
//#import "PlvCourseInfoEntity.h"


NS_ASSUME_NONNULL_BEGIN

// 处理Entity事件
@interface VideoPlayVCInteractor : NSObject

@property (nonatomic, strong) NSMutableArray * rateArray;
@property (nonatomic        ) CGFloat playVideoRate;
@property (nonatomic, copy  ) NSString * definateText;

@end

NS_ASSUME_NONNULL_END
