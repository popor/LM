//
//  MRouterUrlPrefix.h
//  hywj
//
//  Created by popor on 2020/8/30.
//  Copyright © 2020 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MRouterUrlPrefix : NSObject

// 打开关闭控制器
UIKIT_EXTERN NSString * const MUrl_playBarOpen;
UIKIT_EXTERN NSString * const MUrl_playBarClose;

UIKIT_EXTERN NSString * const MUrl_savePlayDepartment;
UIKIT_EXTERN NSString * const MUrl_savePlayConfig;
UIKIT_EXTERN NSString * const MUrl_freshRootTV;
UIKIT_EXTERN NSString * const MUrl_freshFileData; // 刷新文件列表
UIKIT_EXTERN NSString * const MUrl_freshRootVcSetBt; // 显示首页播放页面

UIKIT_EXTERN NSString * const MUrl_updateLrcData;
UIKIT_EXTERN NSString * const MUrl_showLrc;
UIKIT_EXTERN NSString * const MUrl_closeLrc;
UIKIT_EXTERN NSString * const MUrl_updateLrcTime;
UIKIT_EXTERN NSString * const MUrl_playAtTime;


UIKIT_EXTERN NSString * const MUrl_wifiAddFileVC;

UIKIT_EXTERN NSString * const MUrl_appSet;

UIKIT_EXTERN NSString * const MUrl_videoPlayOnly;

@end

NS_ASSUME_NONNULL_END
