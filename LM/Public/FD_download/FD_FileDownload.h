//
//  SDDownload.h
//
//  Created by popor on 15/6/11.
//
// 模仿SDWebImageView方案
// change 'Compile Sources As' to 'Objective-C++'
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// MARK: need add info.plist : [Required background modes]--[App downloads content from the network]

typedef NS_ENUM(NSInteger, FDStatus) {
    //FDStatusClean,
    FDStatusCancle,
    FDStatusNetError,
    FDStatusFinish,
};

typedef void(^FD_ProgressBlock)(CGFloat completeScale);
typedef void(^FD_CompletedBlock)(FDStatus status);

@interface FD_FileDownload:NSObject

@property (nonatomic, strong) NSString * downloadUrl;

@property (nonatomic, strong) NSString * savePath;


+ (FD_FileDownload *)fileUrl:(NSString *)urlStr savePath:(NSString *)savePath progress:(FD_ProgressBlock)progressBlock complete:(FD_CompletedBlock)completedBlock;

- (void)startDownloadFile;
- (void)stopDownloadFile;

@end
