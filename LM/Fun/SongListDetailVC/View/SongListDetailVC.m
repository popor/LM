//
//  SongListDetailVC.m
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.

#import "SongListDetailVC.h"
#import "SongListDetailVCPresenter.h"
#import "SongListDetailVCRouter.h"

@interface SongListDetailVC ()

@property (nonatomic, strong) SongListDetailVCPresenter * present;

@end

@implementation SongListDetailVC
@synthesize infoTV;
@synthesize playbar;
@synthesize listArray;

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [NSAssistant setVC:self dic:dic];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.title) {
        self.title = @"歌单";
    }
    self.view.backgroundColor = [UIColor whiteColor];
    if (!self.present) {
        [SongListDetailVCRouter setVCPresent:self];
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
    self.infoTV = [self addTVs];
    
}

- (UITableView *)addTVs {
    UITableView * oneTV = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
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

@end
