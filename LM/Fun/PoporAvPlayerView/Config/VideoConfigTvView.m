//
//  VideoConfigTvView.m
//  hywj
//
//  Created by popor on 2020/6/15.
//  Copyright © 2020 popor. All rights reserved.
//

#import "VideoConfigTvView.h"
#import "CellAnimationShake.h"

#define CellVH 48.0

@interface VideoConfigTvView() <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>


@end

@implementation VideoConfigTvView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
        self.cellH = 50;
        [self addViews];
    }
    return self;
}

- (void)addViews {
    
    UITapGestureRecognizer * tap = [UITapGestureRecognizer new];
    tap.delegate = self;
    @weakify(self);
    [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        @strongify(self);
        [UIView animateWithDuration:0.15 animations:^{
            self.alpha = 0;
        }];
    }];
    [self addGestureRecognizer:tap];
    tap.delaysTouchesBegan = YES;
    
    self.infoTV = [self addTVs];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

#pragma mark - UITableView
- (UITableView *)addTVs {
    UITableView * oneTV = [[UITableView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 100, 0, 100, self.bounds.size.height) style:UITableViewStyleGrouped];
    oneTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    oneTV.delegate   = self;
    oneTV.dataSource = self;
    
    oneTV.allowsMultipleSelectionDuringEditing = YES;
    oneTV.directionalLockEnabled = YES;
    
    oneTV.estimatedRowHeight           = 0;
    oneTV.estimatedSectionHeaderHeight = 0;
    oneTV.estimatedSectionFooterHeight = 0;
    oneTV.backgroundColor              = PRGBF(0, 0, 0, 0.5);
    
    [self  addSubview:oneTV];
    
    return oneTV;
}

#pragma mark - UITableViewDataSource
TvDelegate_CellShake // tv 只保留震动
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoConfigTvViewCount:)]) {
        return [self.delegate videoConfigTvViewCount:self];
    } else {
        return self.infoArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellH;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat remainH = self.frame.size.height - self.cellH * [self tableView:tableView numberOfRowsInSection:section];
    if (remainH > 0) {
        return remainH/2;
    }
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellID = @"CellID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoConfigTvView:indexPath:cell:)]) {
        [self.delegate videoConfigTvView:self indexPath:indexPath cell:cell];
    } else {
        cell.textLabel.text = self.infoArray[indexPath.row];
        if ([self.selectString isEqualToString:cell.textLabel.text]) {
            cell.textLabel.textColor = App_colorTheme;
        } else {
            cell.textLabel.textColor = [UIColor whiteColor];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoConfigTvView:selectIndex:)]) {
        [self.delegate videoConfigTvView:self selectIndex:indexPath.row];
    }
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    self.selectString = cell.textLabel.text;
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = 0;
    }];
}

- (void)showAtView:(UIView *)view {
    [self showAtView:view tvWidth:-1];
}

- (void)showAtView:(UIView *)view tvWidth:(CGFloat)tvWidth {
    if (self.superview != view) {
        if (self.superview) {
            [self removeFromSuperview];
        }
        [view addSubview:self];
    }
    self.frame = view.bounds;
    
    CGFloat width;
    
    if (tvWidth < 0) {
        width = self.bounds.size.width * 0.35;
        if (CGSizeEqualToSize(self.frame.size, PSCREEN_SIZE)) {
            width = self.bounds.size.width * 0.2;
        }
    } else {
        width = tvWidth;
    }
    
    self.infoTV.frame = CGRectMake(self.bounds.size.width - width, 0, width, self.bounds.size.height);
    [self.infoTV reloadData];
    
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = 1;
    }];
}

@end
