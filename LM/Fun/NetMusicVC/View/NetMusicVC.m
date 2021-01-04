//
//  NetMusicVC.m
//  LM
//
//  Created by 王凯庆 on 2021/1/3.
//  Copyright © 2021 popor. All rights reserved.

#import "NetMusicVC.h"
#import "NetMusicVCPresenter.h"
#import "NetMusicVCInteractor.h"

#import <Masonry/Masonry.h>
#import "FD_FileDownload.h"
#import "MusicPlayListTool.h"

@interface NetMusicVC () <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) NetMusicVCPresenter * present;
@property (nonatomic, copy  ) NSString * lastSaveFileUrl;
@property (nonatomic, copy  ) NSString * lastSaveFileName;

@end

@implementation NetMusicVC
@synthesize infoWV;
@synthesize fileDownloadArray;

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [self assembleViper];
    [super viewDidLoad];
    
    if (!self.title) {
        self.title = @"";
    }
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // 参考: https://www.jianshu.com/p/c244f5930fdf
    if (self.isViewLoaded && !self.view.window) {
        // self.view = nil;//当再次进入此视图中时能够重新调用viewDidLoad方法
        
    }
}

#pragma mark - VCProtocol
- (UIViewController *)vc {
    return self;
}

#pragma mark - viper views
- (void)assembleViper {
    if (!self.present) {
        NetMusicVCPresenter * present = [NetMusicVCPresenter new];
        NetMusicVCInteractor * interactor = [NetMusicVCInteractor new];
        
        self.present = present;
        [present setMyInteractor:interactor];
        [present setMyView:self];
        
        [self addViews];
        [self startEvent];
    }
}

- (void)addViews {
    [self addWebView];
    self.fileDownloadArray = [NSMutableArray new];
    
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    [self.present startEvent];
    
}

// -----------------------------------------------------------------------------
- (void)addWebView {
    
    WKWebViewConfiguration  * configuration   = [[WKWebViewConfiguration alloc] init];
    WKUserContentController * userController  = [[WKUserContentController alloc] init];
    configuration.userContentController = userController;
    configuration.allowsInlineMediaPlayback = YES; // https://www.jianshu.com/p/e1e3eb7d4f7e 允许h5在页面内部播放的配置.
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.allowsInlineMediaPlayback = YES;
    config.requiresUserActionForMediaPlayback = NO;
    
    {   // 注释 音视频js代码
        // https://blog.csdn.net/levebe/article/details/105996359
        //js代码, 这里包房视频播放停止的函数: playPause()
        NSString *videos = @"var myvideo = document.getElementById('myvideo');function playPause(){myvideo.pause()}";
        // 注入网页停止播放音乐的js代码
        WKUserScript *pauseJS = [[WKUserScript alloc]initWithSource:videos injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        
        [userController addUserScript:pauseJS];
    }
    
    
    if (!self.infoWV) {
        WKWebView * web = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) configuration:configuration];
        
        if (@available(iOS 11, *)) {
            //web.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
            web.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        
        {
            //NSLogString(self.rootUrl);
            NSString * musicUrl = @"http://y.webzcz.cn/";
            //musicUrl = @"https://www.126.com";
            NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:musicUrl]];
            
            [web loadRequest:request];
        }
        
        web.UIDelegate         = self;
        web.navigationDelegate = self;
        web.allowsBackForwardNavigationGestures = YES;
        
        [self.view addSubview:web];
        [web mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
        
        self.infoWV = web;
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSURL *URL = navigationAction.request.URL;
    
    NSLogString(URL.absoluteString);
    
    if ([URL.absoluteString.lowercaseString hasSuffix:@".mp3"]) {
        // 自主下载
        self.lastSaveFileUrl = URL.absoluteString;
        
        [self downloadAction];
        
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if([error code] == NSURLErrorCancelled)  {
        return;
    }
    //NSLog(@"PoporWKWebVC error : %@", error.localizedDescription);
//    if (self.webViewLoadErrorBlock) {
//        self.webViewLoadErrorBlock(error);
//    } else if (error) {
//        AlertToastTitleTime(error.localizedDescription, 2);
//    }
//
//    if (self.addPullFresh) {
//        [self.infoWV.scrollView.mj_header endRefreshing];
//    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 加载好之后禁止 选择和查看图片
    [webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
    [webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';"   completionHandler:nil];
    
//    if (self.addPullFresh) {
//        [self.infoWV.scrollView.mj_header endRefreshing];
//    }
}

- (void)downloadAction {
    //
    {
        UIAlertController * oneAC = [UIAlertController alertControllerWithTitle:@"下载" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [oneAC addTextFieldWithConfigurationHandler:^(UITextField *textField){
            
            textField.placeholder = @"歌手名称 - 歌曲名称";
            textField.text = self.lastSaveFileName;
        }];
        
        UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction * changeAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField * nameTF = oneAC.textFields[0];
            if (nameTF.text.length > 0) {
                //NSLog(@"更新 name: %@", nameTF.text);
                self.lastSaveFileName = nameTF.text;
                
                [self downloadEvent];
            }
        }];
        
        [oneAC addAction:cancleAction];
        [oneAC addAction:changeAction];
        
        [self presentViewController:oneAC animated:YES completion:nil];
    }
}

- (void)downloadEvent {
    NSString * savePath = [NSString stringWithFormat:@"%@/%@.mp3", [MusicPlayListTool downloadFolderPath],self.lastSaveFileName];
    NSLogString(savePath);
    
    @weakify(self);
    __block FD_FileDownload * fileDownload = [FD_FileDownload fileUrl:self.lastSaveFileUrl savePath:savePath progress:^(CGFloat completeScale) {
        
    } complete:^(FDStatus status) {
        @strongify(self);
        [self.fileDownloadArray removeObject:fileDownload];
        
        switch (status) {
            case FDStatusCancle : {
                
                break;
            }
            case FDStatusNetError : {
                AlertToastTitle(@"下载失败");
                break;
            }
            case FDStatusFinish : {
                AlertToastTitle(@"下载成功");
                break;
            }
            default:
                break;
        }
    }];
    [self.fileDownloadArray addObject:fileDownload];
    [fileDownload startDownloadFile];
    
}

@end
