//
//  WifiAddFileVC.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import "WifiAddFileVC.h"
#import "WifiAddFileVCPresenter.h"
#import "WifiAddFileVCRouter.h"

#import "FileTool.h"

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
    
#if !TARGET_OS_MACCATALYST
    {
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"端口" style:UIBarButtonItemStylePlain target:self action:@selector(updatePortAction)];
        // [item1 setTitleTextAttributes:@{NSFontAttributeName:Font16} forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItems = @[item1];
    }
#else
    {
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"打开" style:UIBarButtonItemStylePlain target:self action:@selector(openFolderAction)];
        //UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"更改" style:UIBarButtonItemStylePlain target:self action:@selector(setFolderAction)];
        // [item1 setTitleTextAttributes:@{NSFontAttributeName:Font16} forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItems = @[item1];
    }
#endif
    
}

- (void)addServer {
    if (!self.infoL) {
        self.infoL = [UILabel new];
        //self.infoL.insets = UIEdgeInsetsMake(0, 0, 0, 0);
        self.infoL.backgroundColor = [UIColor clearColor];
        self.infoL.font = [UIFont systemFontOfSize:14];
        self.infoL.numberOfLines = 0;
        [self.infoL setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        
        [self.view addSubview:self.infoL];
    }
#if !TARGET_OS_MACCATALYST
    if (!self.webUploader) {
        self.webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:[FileTool getAppDocPath]];
        //[self.webUploader start];
        [self.webUploader startWithPort:[self getPort] bonjourName:@""];
    }
#else
    
#endif
    
    [self updateInfoL];
    
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

- (void)updateInfoL {
    UIFont * font1 = [UIFont systemFontOfSize:16];
    NSMutableAttributedString * att = [NSMutableAttributedString new];
    if (self.webUploader) {
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
    } else {
        [att addString:[NSString stringWithFormat:@"\n1.请将音乐文件夹复制到: %@。", [FileTool getAppDocPath]] font:font1 color:[UIColor blackColor]];
    }
    
    self.infoL.attributedText = att;
}

- (void)updatePortAction {
    UIAlertController * oneAC = [UIAlertController alertControllerWithTitle:@"修改端口号" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [oneAC addTextFieldWithConfigurationHandler:^(UITextField *textField){
        
        textField.placeholder = @"8080";
        textField.text = [NSString stringWithFormat:@"%li", [self getPort]];
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    @weakify(self);
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * changeAction = [UIAlertAction actionWithTitle:@"修改" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        
        UITextField * nameTF = oneAC.textFields[0];
        [self savePort:nameTF.text.integerValue];
        
        [self.webUploader stop];
        [self.webUploader startWithPort:[self getPort] bonjourName:@""];
        
        [self updateInfoL];
    }];
    
    [oneAC addAction:cancleAction];
    [oneAC addAction:changeAction];
    
    [self presentViewController:oneAC animated:YES completion:nil];
}

- (void)savePort:(NSInteger)port {
    if (port > 65535) {
        port = 65535;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%li", port] forKey:@"WifiAddFileVC_port"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)getPort {
    NSString * info = [[NSUserDefaults standardUserDefaults] objectForKey:@"WifiAddFileVC_port"];
    NSInteger port = [info integerValue];
    if (port == 0) {
        port = 8080;
    }
    return port;
}


- (void)openFolderAction {
    NSURL * url = [NSURL fileURLWithPath:@"file:///Users/popor/Desktop/demo/"];
    //url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"file://%@", [FileTool getAppDocPath]]];
    
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
        
    }];
}

- (void)setFolderAction {
    
    
}

@end
