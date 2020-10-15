//
//  LrcView.m
//  LM
//
//  Created by popor on 2020/10/14.
//  Copyright © 2020 popor. All rights reserved.

#import "LrcView.h"
#import "LrcViewPresenter.h"
#import "LrcViewInteractor.h"

@interface LrcView ()

@property (nonatomic, strong) LrcViewPresenter * present;

@end

@implementation LrcView
@synthesize infoTV;
@synthesize closeBT;
@synthesize show;
@synthesize timeL;
@synthesize playBT;
@synthesize lineView1;
@synthesize lineView2;

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
    self.backgroundColor = [UIColor whiteColor];
    
    self.infoTV = [self addTVs];
    [self addBTs];
    [self addMgjrouter];
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    [self.present startEvent];
    
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
    self.closeBT = ({
        UIButton * oneBT = [UIButton buttonWithType:UIButtonTypeClose];
        
        [self.view addSubview:oneBT];
        oneBT;
    });
    
    [self.closeBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40);
        make.right.mas_equalTo(-10);
        
        make.size.mas_equalTo(CGSizeMake(40, 40));
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
        CGSize size = CGSizeMake(160, 1);
        self.lineView1 = ({
            UIImageView * view = [UIImageView new];
            [self.view addSubview:view];
            [self.view sendSubviewToBack:view];
            view;
        });
        self.lineView2 = ({
            UIImageView * view = [UIImageView new];
            [self.view addSubview:view];
            [self.view sendSubviewToBack:view];
            view;
        });
        [self.lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_equalTo(self.timeL.mas_right);
            
            make.size.mas_equalTo(size);
        }];
        [self.lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(self.playBT.mas_left);
            
            make.size.mas_equalTo(size);
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

- (void)addMgjrouter {
    @weakify(self);
    [MRouterC registerURL:MUrl_updateLrcData toHandel:^(NSDictionary *routerParameters){
        @strongify(self);
        
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.infoTV.contentInset = UIEdgeInsetsMake(self.infoTV.height/2, 0, self.infoTV.height/2, 0);
        });
    }
}


@end
