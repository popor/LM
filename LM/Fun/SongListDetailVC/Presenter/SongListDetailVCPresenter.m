//
//  SongListDetailVCPresenter.m
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.

#import "SongListDetailVCPresenter.h"
#import "SongListDetailVCInteractor.h"

#import "MusicInfoCell.h"
#import "MusicPlayBar.h"

@interface SongListDetailVCPresenter ()

@property (nonatomic, weak  ) id<SongListDetailVCProtocol> view;
@property (nonatomic, strong) SongListDetailVCInteractor * interactor;

@property (nonatomic, weak  ) MusicPlayBar * mpb;
@property (nonatomic, weak  ) MusicInfoCell * lastCell;

@end

@implementation SongListDetailVCPresenter

- (id)init {
    if (self = [super init]) {
        self.mpb = MpbShare;
        [self initInteractors];
        
    }
    return self;
}

- (void)setMyView:(id<SongListDetailVCProtocol>)view {
    self.view = view;
}

- (void)initInteractors {
    if (!self.interactor) {
        self.interactor = [SongListDetailVCInteractor new];
    }
}

#pragma mark - VC_DataSource
#pragma mark - TV_Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.view.listArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MusicInfoCellH;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellID = @"CellID";
    MusicInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell) {
        cell = [[MusicInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.addBt.userInteractionEnabled = NO;
        [cell.addBt setImage:nil forState:UIControlStateNormal];
    }
    MusicPlayItemEntity * item = self.view.listArray[indexPath.row];
    
    cell.titelL.text = [NSString stringWithFormat:@"%li: %@", indexPath.row+1, item.musicTitle];
    cell.timeL.text  = item.musicAuthor;
    
    if ([item.filePath isEqualToString:self.mpb.currentItem.filePath]) {
        cell.titelL.textColor = ColorThemeBlue1;
        cell.timeL.textColor  = ColorThemeBlue1;
        
        self.lastCell = cell;
        //cell.backgroundColor = [UIColor redColor];
    }else{
        cell.titelL.textColor = [UIColor blackColor];
        cell.timeL.textColor  = [UIColor grayColor];
        
        //cell.backgroundColor = [UIColor whiteColor];
    }
    if (!item.musicCover) {
        item.musicCover = [item coverImage];
    }
    [cell.addBt setImage:item.musicCover forState:UIControlStateNormal];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
 
    [MpbShare playRecordArray:self.view.listArray at:indexPath.row];
    
    if (self.lastCell) {
        self.lastCell.titelL.textColor = [UIColor blackColor];
        self.lastCell.timeL.textColor  = [UIColor grayColor];
    }
    {
        MusicInfoCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.titelL.textColor = ColorThemeBlue1;
        cell.timeL.textColor  = ColorThemeBlue1;
        
        self.lastCell = cell;
    }
}

#pragma mark - VC_EventHandler

#pragma mark - Interactor_EventHandler

@end
