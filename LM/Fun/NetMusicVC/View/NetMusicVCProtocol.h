//
//  NetMusicVCProtocol.h
//  LM
//
//  Created by 王凯庆 on 2021/1/3.
//  Copyright © 2021 popor. All rights reserved.

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "FD_FileDownload.h"

NS_ASSUME_NONNULL_BEGIN

// MARK: 对外接口
@protocol NetMusicVCProtocol <NSObject>

- (UIViewController *)vc;

// MARK: 自己的
@property (nonatomic, strong) WKWebView * infoWV;
@property (nonatomic, strong) NSMutableArray * fileDownloadArray;

// MARK: 外部注入的

@end

// MARK: 数据来源
@protocol NetMusicVCDataSource <NSObject>

@end

// MARK: UI事件
@protocol NetMusicVCEventHandler <NSObject>

@end

NS_ASSUME_NONNULL_END
