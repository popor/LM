//
//  LrcView.m
//  LM
//
//  Created by popor on 2020/10/14.
//  Copyright © 2020 popor. All rights reserved.

#import "LrcView.h"
#import "LrcViewPresenter.h"
#import "LrcViewInteractor.h"
#import "MusicFolderEntity.h"
#import "MusicPlayBar.h"
#import "MusicPlayTool.h"

@interface LrcView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) LrcViewPresenter * present;
@property (nonatomic, weak  ) MusicPlayBar * mpb;
@property (nonatomic, weak  ) MusicPlayTool * mpt;
@property (nonatomic        ) BOOL showBlurImage_lrc;
@property (nonatomic, copy  ) NSString * lastImageUrl;

@property (nonatomic, strong) AlertWindowImageView * _Nullable awIV;
@property (nonatomic, strong) UILongPressGestureRecognizer * coverIvLpGR;

@end

@implementation LrcView
@synthesize coverSV;
@synthesize coverIV;

@synthesize tvDrag;
@synthesize infoTV;
@synthesize closeBT;
@synthesize show;

@synthesize coverFillBT;
@synthesize coverCloseBT;

@synthesize dragLrcTimeView;
@synthesize timeL;
@synthesize playBT;
@synthesize lineView1;
@synthesize lineView2;
@synthesize coverLrcTapGR;
@synthesize dragLrcTapGR;

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
    self.mpt  = MptShare;
    
    [self addCovers];
    
    self.infoTV = [self addTVs];
    [self addDragBTs];
    [self addCloseBts];
    [self addFillBts];
    [self addTapGrs];
    [self addMgjrouter];
    
    {
        self.dragLrcTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self.present action:@selector(playBTAction:)];
        self.dragLrcTapGR.enabled = NO;
        [self.infoTV addGestureRecognizer:self.dragLrcTapGR];
    }
    {
        [self.view insertSubview:self.lineView1 belowSubview:self.infoTV];
        [self.view insertSubview:self.lineView2 belowSubview:self.infoTV];
    }
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
        oneIV.userInteractionEnabled = YES;
        
        [self.coverSV addSubview:oneIV];
        oneIV;
    });
    
    self.coverIvLpGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editAudioCover)];
    [self.coverIV addGestureRecognizer:self.coverIvLpGR];
    
    [self updateCoverIVContentMode];
}

- (void)editAudioCover {
    if (self.lastImageUrl.length == 0) {
        
        return;
    }
    if (self.awIV) {
        return;
    }
    BOOL isHasImage = [[UIPasteboard generalPasteboard] containsPasteboardTypes:UIPasteboardTypeListImage];
    if (isHasImage) {
        FeedbackShakePhone
        
        UIImage * image = [UIPasteboard generalPasteboard].image;
        
        self.awIV = [[AlertWindowImageView alloc] initWithImage:image cancelButtonTitle:@"取消" confireButtonTitles:@"设置封面"];
        
        @weakify(self);
        [self.awIV showWithBlock:^(BOOL isConfirm) {
            @strongify(self);
            
            [self.awIV removeFromSuperview];
            self.awIV = nil;
            
            
            if (isConfirm) {
                NSData * iamgeData = UIImageJPEGRepresentation(image, 0.9);
                
                NSURL * inputUrl1 = [NSURL URLWithString:self.lastImageUrl];
                NSString * output = [NSString stringWithFormat:@"%@ 2.m4a", [self.lastImageUrl substringToIndex:self.lastImageUrl.length -self.lastImageUrl.pathExtension.length -1]];
                NSURL * outputUrl = [NSURL URLWithString:output];
                
                [MusicPlayTool editAudioFileUrl1:inputUrl1
                                       inputUrl2:nil
                                          output:outputUrl
                                          artist:nil
                                        songName:nil
                                           album:nil
                                         artwork:iamgeData complete:^(BOOL value) {
                    
                    
                }];
            }
        }];
        
    } else {
        FeedbackShakeMedium
        
        //NSLog(@"没有检测到复制图片");
        AlertToastTitle(@"没有检测到复制图片");
        self.coverIvLpGR.enabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.coverIvLpGR.enabled = YES;
        });
    }
    
}

- (void)updateCoverIVContentMode {
    if ([self get__coverImageFull]) {
        self.coverIV.contentMode = UIViewContentModeScaleAspectFill;
    } else {
        self.coverIV.contentMode = UIViewContentModeScaleAspectFit;
    }
}

// -----------------------------------------------------------------------------
- (UITableView *)addTVs {
    UITableView * oneTV = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    oneTV.backgroundColor = PRGBF(0, 0, 0, 0.3);
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

- (void)addDragBTs {
    {
        self.dragLrcTimeView = ({
            UIView * oneView = [UIView new];
            oneView.backgroundColor = UIColor.clearColor;
            oneView.userInteractionEnabled = NO;
            
            [self.view addSubview:oneView];
            oneView;
        });
        
        [self.dragLrcTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(40);
            
        }];
    }
    
    {
        self.timeL = ({
            UILabel * oneL = [UILabel new];
            oneL.backgroundColor     = [UIColor clearColor]; // ios8 之前
            oneL.font                = [UIFont systemFontOfSize:16];
            oneL.textColor           = KDragColor;
            oneL.layer.masksToBounds = YES; // ios8 之后 lableLayer 问题
            oneL.numberOfLines       = 1;
            oneL.userInteractionEnabled = NO;
            
            [self.dragLrcTimeView addSubview:oneL];
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
            [oneBT setTitleColor:KDragColor forState:UIControlStateNormal];
            [oneBT setBackgroundColor:[UIColor clearColor]];
            oneBT.titleLabel.font = [UIFont systemFontOfSize:30];
            oneBT.userInteractionEnabled = NO;
            
            [self.dragLrcTimeView addSubview:oneBT];
            oneBT;
        });
        
        [self.playBT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(-20);
            
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        {
            CGSize size = CGSizeMake(20, 1);
            self.lineView1 = ({
                UIImageView * view = [UIImageView new];
                view.contentMode = UIViewContentModeScaleToFill;
                view.backgroundColor = [UIColor clearColor];
                
                [self.dragLrcTimeView addSubview:view];
                view;
            });
            self.lineView2 = ({
                UIImageView * view = [UIImageView new];
                view.contentMode = UIViewContentModeScaleToFill;
                view.backgroundColor = [UIColor clearColor];
                
                [self.dragLrcTimeView addSubview:view];
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
                
                CGFloat gap = 80;
    #if TARGET_OS_MACCATALYST
                gap = 200;
    #else
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    gap = 400;
                }
    #endif
                make.left.mas_equalTo(self.lineView1.mas_right).mas_offset(gap);
            }];
            
            UIColor * c0 = [KDragColor colorWithAlphaComponent:1];
            UIColor * c1 = [KDragColor colorWithAlphaComponent:0];
            
            UIImage * image1 = [UIImage gradientImageWithBounds:CGRectMake(0, 0, size.width, size.height) andColors:@[c0, c1] gradientHorizon:YES];
            UIImage * image2 = [UIImage gradientImageWithBounds:CGRectMake(0, 0, size.width, size.height) andColors:@[c1, c0] gradientHorizon:YES];
            
            self.lineView1.image = image1;
            self.lineView2.image = image2;
        }
    });
    
    self.dragLrcTimeView.hidden = YES;
}

- (void)addCloseBts {
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
        make.top.mas_equalTo([UIDevice statusBarHeight] +5);
#endif
        
        make.right.mas_equalTo(-15);
        make.size.mas_equalTo(CGSizeMake(btWidth, btWidth));
    }];
    
    [[self.closeBT rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        FeedbackShakePhone
        
        [MGJRouter openURL:MUrl_closeLrc];
    }];
}

- (void)addFillBts {
    CGFloat btWidth = 40;
    self.coverFillBT = ({
        UIButton * oneBT;
        oneBT = [UIButton buttonWithType:UIButtonTypeCustom];
        // https://www.iconfont.cn/search/index?q=屏&page=7
        [oneBT setImage:[UIImage imageNamed:@"全屏"] forState:UIControlStateSelected];
        [oneBT setImage:[UIImage imageNamed:@"半屏"] forState:UIControlStateNormal];
        
        [oneBT setBackgroundImage:[UIImage imageFromColor:PRGB16F(0XB1B1B1, 0.7) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
        
        oneBT.layer.cornerRadius = btWidth/2;
        oneBT.layer.cornerRadius = 4;
        oneBT.clipsToBounds = YES;
        
        [self.view addSubview:oneBT];
        oneBT;
    });
    self.coverCloseBT = ({
        UIButton * oneBT;
        oneBT = [UIButton buttonWithType:UIButtonTypeCustom];
        // https://www.iconfont.cn/search/index?q=屏&page=7
        [oneBT setImage:[UIImage imageNamed:@"封面S"] forState:UIControlStateSelected];
        [oneBT setImage:[UIImage imageNamed:@"封面N"] forState:UIControlStateNormal];
        
        [oneBT setBackgroundImage:[UIImage imageFromColor:PRGB16F(0XB1B1B1, 0.7) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
        
        oneBT.layer.cornerRadius = btWidth/2;
        oneBT.layer.cornerRadius = 4;
        oneBT.clipsToBounds = YES;
        
        [self.view addSubview:oneBT];
        oneBT;
    });
    
    if ([self get__coverImageFull]) {
        self.coverFillBT.selected = YES;
    }
    
    [self.coverFillBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-20);
        make.right.mas_equalTo(-20);
        make.size.mas_equalTo(CGSizeMake(btWidth, btWidth));
    }];
    [self.coverCloseBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.coverFillBT);
        make.right.mas_equalTo(self.coverFillBT.mas_left).mas_offset(-20);
        make.size.mas_equalTo(CGSizeMake(btWidth, btWidth));
    }];
    
    @weakify(self);
    [[self.coverFillBT rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        FeedbackShakePhone
        
        self.coverFillBT.selected = !self.coverFillBT.isSelected;
        [self save__coverImageFull:self.coverFillBT.isSelected];
        
        [self updateCoverIVContentMode];
    }];
    
    [[self.coverCloseBT rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        FeedbackShakePhone
        
        self.coverCloseBT.selected = !self.coverCloseBT.isSelected;
        self.coverIV.hidden = !self.coverIV.hidden;
    }];
}

- (void)addTapGrs {
    self.coverLrcTapGR = [UITapGestureRecognizer new];
    //self.tapGR.delegate = self;
    [self.view addGestureRecognizer:self.coverLrcTapGR];
    
    @weakify(self);
    [[self.coverLrcTapGR rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        @strongify(self);
        FeedbackShakePhone
        
        if (self.tvDrag) {
            [self.present endDragDelay];
        } else {
            self.showBlurImage_lrc = !self.showBlurImage_lrc;
            [self showCoverBlurImage];
            [self.present endDragDelay];
        }
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.coverLrcTapGR) {
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
#if TARGET_OS_MACCATALYST
        self.coverSV.frame = CGRectMake(0, 20, self.width, self.height -20);
#else
        self.coverSV.frame = CGRectMake(0, 0, self.width, self.height -0);
#endif
        self.coverIV.frame = self.coverSV.bounds;
    }
}

- (void)showCoverBlurImage {
    if (![self.lastImageUrl isEqualToString:self.mpt.audioPlayer.url.absoluteString]) {
        self.lastImageUrl = self.mpt.audioPlayer.url.absoluteString;
        UIImage * coverImage = [MusicPlayTool imageOfUrl:self.mpt.audioPlayer.url];
        coverImage = coverImage ? : self.mpt.defaultCoverImage;
        
        self.coverIV.image = coverImage;
    }
    [UIView animateWithDuration:0.3 animations:^{
        if (self.showBlurImage_lrc) {
            self.infoTV.alpha  = 1;
            self.infoTV.hidden = NO;
        } else {
            self.infoTV.alpha  = 0;
            self.infoTV.hidden = YES;
        }
    }];
    
    // 生成蒙层图片非常消耗内存, 300-600MB, 老手机会非常卡顿, 所以移除了.
    //UIColor *tintColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    //coverImage = [coverImage applyBlurWithRadius:5 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
    //if (self.showBlurImage_lrc) {
    //    coverImage = [coverImage applyDarkEffect];
    //    self.infoTV.hidden = NO;
    //} else {
    //    self.infoTV.hidden = YES;
    //}
    
    
}


- (void)save__coverImageFull:(BOOL)coverImageFull {
    [[NSUserDefaults standardUserDefaults] setObject:@(coverImageFull) forKey:@"coverImageFull"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)get__coverImageFull {
    NSString * info = [[NSUserDefaults standardUserDefaults] objectForKey:@"coverImageFull"];
    return [info boolValue];
}


@end
