//
//  WifiAddFileVCProtocol.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import <UIKit/UIKit.h>

#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"

#import "GCDWebUploader.h"

//#import "UILabelInsets.h"

//#import <PoporUI/UILabel+pInsets.h>

// MARK: 对外接口
@protocol WifiAddFileVCProtocol <NSObject>

- (UIViewController *)vc;
- (void)setMyPresent:(id)present;

// MARK: 自己的
@property (nonatomic, strong) GCDWebUploader * webUploader;
@property (nonatomic, strong) UILabel * infoL;
// MARK: 外部注入的
@property (nonatomic, copy  ) BlockPVoid deallocBlock;

@end

// MARK: 数据来源
@protocol WifiAddFileVCDataSource <NSObject>

@end

// MARK: UI事件
@protocol WifiAddFileVCEventHandler <NSObject>

@end
