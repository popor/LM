//
//  LocalMusicVC.m
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.

#import "LocalMusicVC.h"
#import "LocalMusicVCPresenter.h"
#import "LocalMusicVCRouter.h"

@interface LocalMusicVC ()

@property (nonatomic, strong) LocalMusicVCPresenter * present;

@end

@implementation LocalMusicVC
@synthesize infoTV;
@synthesize musicListTV;
@synthesize musicPlayboard;
@synthesize itemArray;
@synthesize deallocBlock;

- (void)dealloc {
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
        self.title = @"LocalMusicVC";
    }
    self.view.backgroundColor = [UIColor whiteColor];
    if (!self.present) {
        [LocalMusicVCRouter setVCPresent:self];
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
    self.infoTV      = [self addTVs];
    self.musicListTV = [self addMusicListTVs];
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

- (UITableView *)addMusicListTVs {
    UITableView * oneTV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 200, 250) style:UITableViewStylePlain];
    
    oneTV.delegate   = self.present;
    oneTV.dataSource = self.present;
    
    oneTV.allowsMultipleSelectionDuringEditing = YES;
    oneTV.directionalLockEnabled = YES;
    
    oneTV.estimatedRowHeight           = 0;
    oneTV.estimatedSectionHeaderHeight = 0;
    oneTV.estimatedSectionFooterHeight = 0;
    
    oneTV.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    oneTV.backgroundColor = [UIColor clearColor];
    
    return oneTV;
}



@end
