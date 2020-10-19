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
@property (nonatomic        ) NSInteger dragTime;
@property (nonatomic        ) NSInteger dragRow;

@property (nonatomic        ) NSInteger playRow;

@property (nonatomic, copy  ) UIColor * cellTextColorN;
@property (nonatomic, copy  ) UIColor * cellTextColorS;

@end

@implementation LrcViewPresenter

- (id)init {
    if (self = [super init]) {
        self.cellTextColorN = [UIColor whiteColor];
        self.cellTextColorS = App_textSColor;
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

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return LrcViewTvCellDefaultH;
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
        cell.backgroundColor = [UIColor clearColor];
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.numberOfLines = 0;
        
#if TARGET_OS_MACCATALYST
        cell.textLabel.font = [UIFont systemFontOfSize:26];
#elif TARGET_OS_IPAD
        cell.textLabel.font = [UIFont systemFontOfSize:26];
#else
        cell.textLabel.font = [UIFont systemFontOfSize:18];
#endif
        
    }
    if (self.lrcArray.count == 0) {
        cell.textLabel.text = @"暂无歌词";
        cell.textLabel.textColor = self.cellTextColorN;
        
    } else {
        LrcDetailEntity * entity = self.lrcArray[indexPath.row];
        cell.textLabel.text = entity.lrcText;
        //cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", entity.timeText, entity.lrc];
        if (self.playRow == indexPath.row) {
            cell.textLabel.textColor = self.cellTextColorS;
        } else {
            cell.textLabel.textColor = self.cellTextColorN;
        }
    }
    
    
    return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//
//}

#pragma mark - tv drag
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.view.infoTV) {
        if (self.view.tvDrag && self.lrcArray.count > 0) {
            NSIndexPath * indexPath = [self.view.infoTV indexPathForRowAtPoint:CGPointMake(1, self.view.infoTV.height/2 +scrollView.contentOffset.y)];
            LrcDetailEntity * entity = self.lrcArray[indexPath.row];
            // NSLog(@"%i %@", (int)indexPath.row, entity.timeText);
            self.view.timeL.text = entity.timeText5;
            self.dragTime = entity.time;
            self.dragRow  = entity.row;
        }
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.view.infoTV) {
        if (self.lrcArray.count > 0) {
            self.view.tvDrag = YES;
            self.view.timeL.hidden     = NO;
            self.view.playBT.hidden    = NO;
            self.view.lineView1.hidden = NO;
            self.view.lineView2.hidden = NO;
        } else {
            [self endDragDelay];
        }
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(endDragDelay) object:nil];
    }
   
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.view.infoTV) {
        if (self.lrcArray.count > 0) {
            [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(endDragDelay) object:nil];
            [self performSelector:@selector(endDragDelay) withObject:nil afterDelay:5];
        }
    }
    
}

#pragma mark - sv zoom
- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView {
    if (scrollView == self.view.coverSV) {
        return self.view.coverIV;
    }
    
    return nil;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView == self.view.coverSV) {

        [self zoomSV:scrollView view:self.view.coverIV];
    }
}

- (void)zoomSV:(UIScrollView *)sv view:(UIView *)zoomView {
    CGRect zoomRect   = zoomView.frame;
    
    if (zoomRect.size.width < sv.bounds.size.width) {
        zoomRect.origin.x = (sv.bounds.size.width - zoomRect.size.width) * 0.5;
    } else {
        zoomRect.origin.x = 0.0;
    }
    if (zoomRect.size.height < sv.bounds.size.height) {
        zoomRect.origin.y = (sv.bounds.size.height - zoomRect.size.height) * 0.5;
    } else {
        zoomRect.origin.y = 0.0;
    }
    zoomView.frame = zoomRect;
}

- (void)endDragDelay {
    self.view.tvDrag = NO;
    self.view.timeL.hidden     = YES;
    self.view.playBT.hidden    = YES;
    self.view.lineView1.hidden = YES;
    self.view.lineView2.hidden = YES;
}

#pragma mark - VC_EventHandler
- (void)updateLrcArray:(NSArray *)array {
    self.lrcArray = array;
    self.playRow  = 0;
    
    [self endDragDelay];
    [self.view.infoTV reloadData];
    [self scrollToRow:0];
}

- (void)scrollToTopIfNeed {
    if (self.playRow == 0) {
        [self scrollToRow:0];
    }
}

- (void)scrollToLrc:(LrcDetailEntity *)lyric {
    if (self.view.tvDrag) {
        
    } else {
        if (self.playRow != lyric.row) {
            self.playRow = lyric.row;
            //NSLog(@"歌词 time: %@", lyric.timeText);
            
            NSArray * ipArray = self.view.infoTV.indexPathsForVisibleRows;
            NSIndexPath * ip0 = ipArray.firstObject;
            NSIndexPath * ip1 = ipArray.lastObject;
            if (ip0.row <= self.playRow && self.playRow <= ip1.row) {
                // 假如拖拽范围少, 在屏幕显示内部, 则需要刷新可见范围cell.
                [self freshVisiablCell];
            }
            
            [self scrollToRow:lyric.row];
        }
    }
}

- (void)freshVisiablCell {
    for (UITableViewCell * cell in self.view.infoTV.visibleCells) {
        if (cell) {
            NSIndexPath * ip = [self.view.infoTV indexPathForCell:cell];
            if (ip.row == self.playRow) {
                cell.textLabel.textColor = self.cellTextColorS;
            } else {
                cell.textLabel.textColor = self.cellTextColorN;
            }
        }
    }
}

- (void)scrollToRow:(NSInteger)row {
    self.view.infoTV.showsVerticalScrollIndicator = NO;
    NSIndexPath * ip = [NSIndexPath indexPathForRow:row inSection:0];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.view.infoTV scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.view.infoTV.showsVerticalScrollIndicator = YES;
    });
}

- (void)playBTAction {
    NSDictionary * dic = @{@"time":@(self.dragTime)};
    [MGJRouter openURL:MUrl_playAtTime withUserInfo:dic completion:nil];
    
    self.playRow = self.dragRow;
    [self freshVisiablCell];
    
    [self endDragDelay];
}

#pragma mark - Interactor_EventHandler

@end
