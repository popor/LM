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
@synthesize lrcArray;
@synthesize closeBT;
@synthesize show;

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
    
    oneTV.backgroundColor = App_bgColor4;
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
}
- (void)addMgjrouter {
    @weakify(self);
    [MRouterC registerURL:MUrl_updateLrcData toHandel:^(NSDictionary *routerParameters){
        @strongify(self);
        
        NSMutableDictionary * dic = [MRouterC mixDic:routerParameters];
        self.lrcArray = dic[@"lrcArray"];
        
        [self.infoTV reloadData];
    }];
}

@end
