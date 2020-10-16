//
//  LrcView.m
//  LM
//
//  Created by popor on 2020/10/14.
//  Copyright © 2020 popor. All rights reserved.

#import "LrcView.h"
#import "LrcViewPresenter.h"
#import "LrcViewInteractor.h"
#import "MusicPlayListTool.h"
#import "MusicPlayBar.h"
#import "MusicPlayListTool.h"
#import "MusicPlayTool.h"

@interface LrcView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) LrcViewPresenter * present;
@property (nonatomic, weak  ) MusicPlayBar * mpb;
@property (nonatomic, weak  ) MusicPlayListTool * mplt;
@property (nonatomic, weak  ) MusicPlayTool * mpt;
@property (nonatomic        ) BOOL showBlurImage_lrc;

@end

@implementation LrcView
@synthesize coverSV;
@synthesize coverIV;

@synthesize infoTV;
@synthesize closeBT;
@synthesize show;
@synthesize timeL;
@synthesize playBT;
@synthesize lineView1;
@synthesize lineView2;
@synthesize tapGR;

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [self assembleViper];
        self.clipsToBounds = YES;
        
    }
    return self;
}

#pragma mark - VCProtocol
- (UIView *)view {
    return self;
}

- (void)setShow:(BOOL)show1 {
    show = show1;
    self.mpb.showLrc = show;
}

#pragma mark - viper views
- (void)assembleViper {
    if (!self.present) {
        LrcViewPresenter * present = [LrcViewPresenter new];
        LrcViewInteractor * interactor = [LrcViewInteractor new];
        
        self.present = present;
        [present setMyInteractor:interactor];
        [present setMyView:self];
        
        [self addViews];
        [self startEvent];
    }
}

- (void)addViews {
    self.backgroundColor = [UIColor blackColor];
    self.mpb  = MpbShare;
    self.mplt = MpltShare;
    self.mpt  = MptShare;
    
    [self addCovers];
    
    self.infoTV = [self addTVs];
    [self addBTs];
    [self addTapGrs];
    [self addMgjrouter];
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    [self.present startEvent];
    
}

- (void)addCovers {
    self.showBlurImage_lrc = YES;
    
    self.coverSV = ({
        UIScrollView * sv = [UIScrollView new];
        sv.backgroundColor = [UIColor blackColor];
        sv.delegate = self.present;
        
        sv.minimumZoomScale = 0.25;
        sv.maximumZoomScale = 2.0;
        
        [self.view addSubview:sv];
        sv;
    });
    self.coverIV = ({
        UIImageView * oneIV = [UIImageView new];
        oneIV.contentMode = UIViewContentModeScaleAspectFill;
        
        [self.coverSV addSubview:oneIV];
        oneIV;
    });
}

// -----------------------------------------------------------------------------
- (UITableView *)addTVs {
    UITableView * oneTV = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    oneTV.backgroundColor = [UIColor clearColor];
    oneTV.separatorColor  = [UIColor clearColor];
    
    oneTV.delegate   = self.present;
    oneTV.dataSource = self.present;
    
    oneTV.allowsMultipleSelectionDuringEditing = YES;
    oneTV.directionalLockEnabled = YES;
    
    oneTV.estimatedRowHeight           = 0;
    oneTV.estimatedSectionHeaderHeight = 0;
    oneTV.estimatedSectionFooterHeight = 0;
    
    [self.view addSubview:oneTV];
    
    [oneTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    return oneTV;
}

- (void)addBTs {
    CGFloat btWidth = 40;
    self.closeBT = ({
        UIButton * oneBT;
        oneBT = [UIButton buttonWithType:UIButtonTypeCustom];
        [oneBT setTitle:@"X" forState:UIControlStateNormal];
        [oneBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        oneBT.titleLabel.font = [UIFont systemFontOfSize:22];
        //[oneBT setBackgroundImage:[UIImage imageFromColor:PRGB16(0XEFEFF0) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
        [oneBT setBackgroundImage:[UIImage imageFromColor:PRGB16(0XB1B1B1) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
        
        oneBT.layer.cornerRadius = btWidth/2;
        oneBT.clipsToBounds = YES;
        
        [self.view addSubview:oneBT];
        oneBT;
    });
    
    [self.closeBT mas_makeConstraints:^(MASConstraintMaker *make) {
#if TARGET_OS_MACCATALYST
        make.top.mas_equalTo(40);
#else
        make.top.mas_equalTo(20);
#endif
        
        make.right.mas_equalTo(-10);
        make.size.mas_equalTo(CGSizeMake(btWidth, btWidth));
    }];
    
    [[self.closeBT rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [MGJRouter openURL:MUrl_closeLrc];
    }];
    
    {
        self.timeL = ({
            UILabel * oneL = [UILabel new];
            oneL.backgroundColor     = [UIColor clearColor]; // ios8 之前
            oneL.font                = [UIFont systemFontOfSize:16];
            oneL.textColor           = App_textSColor;
            oneL.layer.masksToBounds = YES; // ios8 之后 lableLayer 问题
            oneL.numberOfLines       = 1;
            
            [self.view addSubview:oneL];
            oneL;
        });
        [self.timeL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_equalTo(20);
            
            make.size.mas_equalTo(CGSizeMake(50, 40));
        }];
    }
    {
        self.playBT = ({
            UIButton * oneBT = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [oneBT setTitle:@"▶" forState:UIControlStateNormal];
            [oneBT setTitleColor:App_textSColor forState:UIControlStateNormal];
            [oneBT setBackgroundColor:[UIColor clearColor]];
            oneBT.titleLabel.font = [UIFont systemFontOfSize:30];
            
            [self.view addSubview:oneBT];
            
            [oneBT addTarget:self.present action:@selector(playBTAction) forControlEvents:UIControlEventTouchUpInside];
            
            oneBT;
        });
        
        [self.playBT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(-20);
            
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
    }
    {
        CGSize size = CGSizeMake(20, 1);
        self.lineView1 = ({
            UIImageView * view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleToFill;
            
            [self.view addSubview:view];
            [self.view sendSubviewToBack:view];
            view;
        });
        self.lineView2 = ({
            UIImageView * view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleToFill;
            
            [self.view addSubview:view];
            [self.view sendSubviewToBack:view];
            view;
        });
        [self.lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_equalTo(self.timeL.mas_right);
            
            make.height.mas_equalTo(size.height);
        }];
        [self.lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(self.playBT.mas_left);
            
            make.height.mas_equalTo(size.height);
            make.width.mas_equalTo(self.lineView1.mas_width);
            make.left.mas_equalTo(self.lineView1.mas_right).mas_offset(80);
        }];
        
        UIColor * whiteColor = PRGBF(255, 255, 255, 1);
        UIImage * image1 = [UIImage gradientImageWithBounds:CGRectMake(0, 0, size.width, size.height) andColors:@[ColorThemeBlue1, whiteColor] gradientHorizon:YES];
        UIImage * image2 = [UIImage gradientImageWithBounds:CGRectMake(0, 0, size.width, size.height) andColors:@[whiteColor, ColorThemeBlue1] gradientHorizon:YES];
        
        self.lineView1.image = image1;
        self.lineView2.image = image2;
    }
    self.timeL.hidden     = YES;
    self.playBT.hidden    = YES;
    self.lineView1.hidden = YES;
    self.lineView2.hidden = YES;
}

- (void)addTapGrs {
    self.tapGR = [UITapGestureRecognizer new];
    //self.tapGR.delegate = self;
    [self.view addGestureRecognizer:self.tapGR];
    
    @weakify(self);
    [[self.tapGR rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        @strongify(self);
        self.showBlurImage_lrc = !self.showBlurImage_lrc;
        [self showCoverBlurImage];
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.tapGR) {
        if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
            return YES;
        }
    }
    
    return  YES;
}

- (void)addMgjrouter {
    @weakify(self);
    [MRouterC registerURL:MUrl_updateLrcData toHandel:^(NSDictionary *routerParameters){
        @strongify(self);
        
        [self.coverSV setZoomScale:1];
        [self showCoverBlurImage];
        
        NSMutableDictionary * dic = [MRouterC mixDic:routerParameters];
        [self.present updateLrcArray:dic[@"lrcArray"]];
    }];
    
    [MRouterC registerURL:MUrl_updateLrcTime toHandel:^(NSDictionary *routerParameters){
        @strongify(self);
        
        if (self.isShow) {
            NSMutableDictionary * dic = [MRouterC mixDic:routerParameters];
            LrcDetailEntity * lyric   = dic[@"lyric"];
            
            [self.present scrollToLrc:lyric];
        }
    }];
}

- (void)updateInfoTVContentInset {
    if (self.isShow) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.infoTV.contentInset = UIEdgeInsetsMake(self.infoTV.height/2 -LrcViewTvCellDefaultH, 0, self.infoTV.height/2 -LrcViewTvCellDefaultH, 0);
            
#if TARGET_OS_MACCATALYST
            self.coverSV.frame = CGRectMake(0, 20, self.width, self.height -20);
#else
            self.coverSV.frame = CGRectMake(0, 0, self.width, self.height -0);
#endif
            
            self.coverIV.frame = self.coverSV.bounds;
            
            [self.present scrollToTopIfNeed];
        });
        self.coverSV.frame = CGRectMake(0, 0, self.width, self.height);
        self.coverIV.frame = self.coverSV.bounds;
    }
}

- (void)showCoverBlurImage {
    UIImage * coverImage = [MusicPlayTool imageOfUrl:self.mpt.audioPlayer.url];
    coverImage = coverImage ? : self.mpt.defaultCoverImage;
    
    //UIColor *tintColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    //coverImage = [coverImage applyBlurWithRadius:5 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
    if (self.showBlurImage_lrc) {
        coverImage = [coverImage applyDarkEffect];
        self.infoTV.hidden = NO;
    } else {
        self.infoTV.hidden = YES;
    }
    
    self.coverIV.image = coverImage;
}

@end
