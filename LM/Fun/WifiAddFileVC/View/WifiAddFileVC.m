//
//  WifiAddFileVC.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import "WifiAddFileVC.h"
#import "WifiAddFileVCPresenter.h"
#import "WifiAddFileVCRouter.h"

@interface WifiAddFileVC ()

@property (nonatomic, strong) WifiAddFileVCPresenter * present;

@end

@implementation WifiAddFileVC
@synthesize webUploader;
@synthesize infoL;
@synthesize deallocBlock;


- (void)dealloc {
    [self.webUploader stop];
    self.webUploader = nil;
    
    if (self.deallocBlock) {
        self.deallocBlock();
    }
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [NSAssistant setVC:self dic:dic];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.title) {
        self.title = @"Wifi添加歌曲";
    }
    self.view.backgroundColor = [UIColor whiteColor];
    if (!self.present) {
        [WifiAddFileVCRouter setVCPresent:self];
    }
    
    [self addViews];
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

- (void)setMyPresent:(id)present {
    self.present = present;
}

#pragma mark - views
- (void)addViews {
    [self addServer];
    
}

- (void)addServer {
    if (!self.infoL) {
        self.infoL = [[UILabelInsets alloc] initWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        self.infoL.backgroundColor = [UIColor clearColor];
        self.infoL.font = [UIFont systemFontOfSize:14];
        self.infoL.numberOfLines = 0;
        [self.infoL setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        
        [self.view addSubview:self.infoL];
    }
    
    if (!self.webUploader) {
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        self.webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
        [self.webUploader start];
    }
    UIFont * font1 = [UIFont systemFontOfSize:16];
    NSMutableAttributedString * att = [NSMutableAttributedString new];
    if (!self.webUploader.serverURL) {
        [att addString:@"1.通过wifi添加文件\n    " font:font1 color:[UIColor blackColor]];
        [att addString:@"未开启wifi或者无法获得IP地址" font:font1 color:[UIColor redColor]];
    }else{
        // NSLog(@"Visit %@ in your web browser", self.webUploader.serverURL);
        [att addString:@"1.通过wifi添加文件，访问网址:\n    " font:font1 color:[UIColor blackColor]];
        [att addString:self.webUploader.serverURL.absoluteString font:font1 color:[UIColor redColor]];
    }
    [att addString:@"\n2.通过itunes将文件放置到Document文件目录下。" font:font1 color:[UIColor blackColor]];
    [att addString:@"\n3.只支持1层文件夹，暂不支持多层。\n 根目录只支持文件夹，一级目录只支持mp3文件。" font:font1 color:[UIColor redColor]];
    [att addString:@"\n4.上传文件过程中，请勿关闭本页面、误锁屏。" font:font1 color:[UIColor redColor]];
    
    self.infoL.attributedText = att;
    
    self.infoL.preferredMaxLayoutWidth = 100;
    [self.infoL setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    self.infoL.numberOfLines =0;
    [self.infoL mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        //make.bottom.mas_equalTo(-20);
    }];
}

@end
