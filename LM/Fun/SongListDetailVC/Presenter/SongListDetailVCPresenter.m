//
//  SongListDetailVCPresenter.m
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.

#import "SongListDetailVCPresenter.h"
#import "SongListDetailVCInteractor.h"

@interface SongListDetailVCPresenter ()

@property (nonatomic, weak  ) id<SongListDetailVCProtocol> view;
@property (nonatomic, strong) SongListDetailVCInteractor * interactor;

@end

@implementation SongListDetailVCPresenter

- (id)init {
    if (self = [super init]) {
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
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellID = @"CellID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    MusicPlayItemEntity * item = self.view.listArray[indexPath.row];
    cell.textLabel.text = item.fileName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
 
    [MpbShare playArray:self.view.listArray at:indexPath.row];
}

#pragma mark - VC_EventHandler

#pragma mark - Interactor_EventHandler

@end
