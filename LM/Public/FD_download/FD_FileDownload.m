//
//  SDDownload.m
//
//  Created by popor on 15/6/11.
//

#import "FD_FileDownload.h"
//#import <CommonCrypto/CommonDigest.h>
//#import <objc/runtime.h>

static NSString * kTHDownLoadTask_TempSuffix = @".TempDownload";


@interface FD_FileDownload () <NSURLSessionDelegate>

@property (nonatomic, copy  ) FD_ProgressBlock         fd_ProgressBlock;
@property (nonatomic, copy  ) FD_CompletedBlock        fd_CompletedBlock;

@property (        nonatomic) BOOL                     userCancleDownload;


@property (nonatomic, strong) NSURLSession             *backgroundURLSession;
@property (nonatomic, strong) NSURLSessionDownloadTask * _Nullable task;
@property (nonatomic, strong) NSData * _Nullable fileData;
@property (nonatomic, strong) NSString * tempPath;

@end

@implementation FD_FileDownload

+ (FD_FileDownload *)fileUrl:(NSString *)urlStr savePath:(NSString *)savePath progress:(FD_ProgressBlock)progressBlock complete:(FD_CompletedBlock)completedBlock {
    if (!urlStr ||
        !savePath) {
        return nil;
    }
    FD_FileDownload * downloader = [[FD_FileDownload alloc] init];
    downloader.savePath          = savePath;
    downloader.tempPath          = [savePath stringByAppendingString:kTHDownLoadTask_TempSuffix];
    
    downloader.downloadUrl       = urlStr;
    downloader.fd_ProgressBlock  = progressBlock;
    downloader.fd_CompletedBlock = completedBlock;
    
    return downloader;
}

- (void)startDownloadFile {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.savePath]) {
        [self completeProgress:1.0];
        [self completeStatus:FDStatusFinish];
        return;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.tempPath]) {
        // create cache file
        [[NSFileManager defaultManager] createDirectoryAtPath:self.tempPath.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:nil];
        
        BOOL createSucces = [[NSFileManager defaultManager] createFileAtPath:self.tempPath contents:nil attributes:nil];
        if (!createSucces){
            NSLog(@"create cache file failed!!!!!");
            return;
        }
    }
    [self initConnection];
}

- (void)initConnection {
    _fileData = [NSData dataWithContentsOfFile:self.tempPath];
    
    if (_fileData && _fileData.length > 0) {
        _task = [self.backgroundURLSession downloadTaskWithResumeData:_fileData];
    } else {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.downloadUrl]];
        
        [request setTimeoutInterval:10];
        _task = [self.backgroundURLSession downloadTaskWithRequest:request];
    }
    _task.taskDescription = [NSString stringWithFormat:@"后台下载"];
    
    [_task resume];
}

#pragma mark - NSURLSessionDownloadTaskDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:self.savePath] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:self.tempPath error:nil];
    _fileData = nil;
    
    [self completeStatus:FDStatusFinish];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    CGFloat progress = totalBytesWritten*1.0/totalBytesExpectedToWrite;
    [self completeProgress:progress];
    //NSLog(@"%@", [NSString stringWithFormat:@"下载中,进度为%.2f",progress]);
}

// 停止接口
- (void)stopDownloadFile {
    @weakify(self);
    [_task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        @strongify(self);
        
        self.fileData = resumeData;
        self.task = nil;
        self.userCancleDownload = YES;
        
        [resumeData writeToFile:self.tempPath atomically:YES];
    }];
}

#pragma mark - block 回调
- (void)completeProgress:(CGFloat)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.fd_ProgressBlock) {
            self.fd_ProgressBlock(progress);
        }
    });
}

- (void)completeStatus:(FDStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.fd_CompletedBlock) {
            if (self.userCancleDownload) {
                self.userCancleDownload = NO;
                self.fd_CompletedBlock(FDStatusCancle);
            }else{
                self.fd_CompletedBlock(status);
            }
        }
    });
}

#pragma mark - get

- (NSURLSession *)backgroundURLSession {
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:self.downloadUrl];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    return session;
}

@end


