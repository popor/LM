//
//  LrcViewPresenter.m
//  LM
//
//  Created by popor on 2020/10/14.
//  Copyright © 2020 popor. All rights reserved.

#import "LrcViewPresenter.h"
#import "LrcViewInteractor.h"

@interface LrcViewPresenter ()

@property (nonatomic, weak  ) id<LrcViewProtocol> view;
@property (nonatomic, strong) LrcViewInteractor * interactor;

@property (nonatomic, copy  ) NSArray * lrcArray;
@property (nonatomic        ) BOOL tvDrag;
@property (nonatomic        ) NSInteger playRow;

@end

@implementation LrcViewPresenter

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)setMyInteractor:(LrcViewInteractor *)interactor {
    self.interactor = interactor;
    
}

- (void)setMyView:(id<LrcViewProtocol>)view {
    self.view = view;
    
}

// 开始执行事件,比如获取网络数据
- (void)startEvent {
    
    
}

#pragma mark - VC_DataSource
#pragma mark - TV_Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(self.lrcArray.count, 1);
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 44;
//}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellID = @"CellID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    if (self.lrcArray.count == 0) {
        cell.textLabel.text = @"暂无歌词";
        cell.textLabel.textColor = App_textNColor;
        
    } else {
        LrcDetailEntity * entity = self.lrcArray[indexPath.row];
        cell.textLabel.text = entity.lrc;
        if (self.playRow == indexPath.row) {
            cell.textLabel.textColor = App_textSColor;
        } else {
            cell.textLabel.textColor = App_textNColor;
        }
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - tv drag
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.tvDrag = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tvDrag = NO;
    });
}

#pragma mark - VC_EventHandler
- (void)updateLrcArray:(NSArray *)array {
    self.lrcArray = array;
    self.playRow  = 0;
    [self.view.infoTV reloadData];
}

- (void)scrollToLrc:(LrcDetailEntity *)lyric {
    self.playRow = lyric.row;
    
    if (self.tvDrag) {
        
    } else {
        self.playRow = lyric.row;
        
        for (UITableViewCell * cell in self.view.infoTV.visibleCells) {
            if (cell) {
                NSIndexPath * ip = [self.view.infoTV indexPathForCell:cell];
                if (ip.row == self.playRow) {
                    cell.textLabel.textColor = App_textSColor;
                } else {
                    cell.textLabel.textColor = App_textNColor;
                }
            }
        }
        
        self.view.infoTV.showsVerticalScrollIndicator = NO;
        NSIndexPath * ip = [NSIndexPath indexPathForRow:lyric.row inSection:0];
        
        [self.view.infoTV scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.view.infoTV.showsVerticalScrollIndicator = YES;
        });
    }
}

#pragma mark - Interactor_EventHandler

@end
