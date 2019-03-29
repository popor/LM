//
//  RootVCPresenter.m
//  LM
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019 popor. All rights reserved.

#import "RootVCPresenter.h"
#import "RootVCInteractor.h"

#import "MusicPlayTool.h"
#import "WifiAddFileVCRouter.h"
#import "LocalMusicVCRouter.h"

@interface RootVCPresenter ()

@property (nonatomic, weak  ) id<RootVCProtocol> view;
@property (nonatomic, strong) RootVCInteractor * interactor;

@end

@implementation RootVCPresenter

- (id)init {
    if (self = [super init]) {
        [self initInteractors];
        
    }
    return self;
}

- (void)setMyView:(id<RootVCProtocol>)view {
    self.view = view;
}

- (void)initInteractors {
    if (!self.interactor) {
        self.interactor = [RootVCInteractor new];
    }
}

#pragma mark - VC_DataSource
#pragma mark - TV_Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.view.alertBubbleTV) {
        return RootMoreArray.count;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.alertBubbleTV) {
        return 44;
    }else{
        return 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.view.alertBubbleTV) {
        return 0.1;
    }else{
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView == self.view.alertBubbleTV) {
        return 0.1;
    }else{
        return 10;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.view.alertBubbleTV) {
        static NSString * CellID = @"CellID";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            //cell.backgroundColor = self.alertBubbleTVColor;
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        
        cell.textLabel.text = RootMoreArray[indexPath.row];
        
        return cell;
    }else{
        static NSString * CellID = @"CellID";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%li", indexPath.row];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.view.alertBubbleTV) {
        [self.view.alertBubbleView closeEvent];
        switch (indexPath.row) {
            case 0:{
                
                break;
            }
            case 1:{
                [self showWifiVC];
                break;
            }
            case 2:{
                [self showLocalMusicVC];
                break;
            }
            default:
                break;
        }
        
    }else{
        
    }
    
    
    
}

#pragma mark - VC_EventHandler

- (void)playBTEvent {
    

    NSString *path;
    path = [[NSBundle mainBundle] pathForResource:@"杨凯莉 - 让我做你的眼睛" ofType:@"mp3"];
    //path = [[NSBundle mainBundle] pathForResource:@"a" ofType:@"mp3"];
    
    NSURL * url = [NSURL fileURLWithPath:path];
    [MPTool playEvent:url];
}

- (void)pauseEvent {
    [MPTool pauseEvent];
}

- (void)previousBTEvent {
    
}

- (void)nextBTEvent {
    
}

- (void)rewindBTEvent {
    
}

- (void)forwardBTEvent {
    
}

- (void)showTVAlertAction:(UIBarButtonItem *)sender event:(UIEvent *)event {
    //CGRect fromRect = [[event.allTouches anyObject] view].frame;
    UITouch * touch = [event.allTouches anyObject];
    //UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    
    //CGPoint point = [touch locationInView:window];
    //fromRect.origin = point;
    
    CGRect fromRect = [touch.view.superview convertRect:touch.view.frame toView:self.view.vc.navigationController.view];
    fromRect.origin.y -= 8;
    
    NSDictionary * dic = @{
                           @"direction":@(AlertBubbleViewDirectionTop),
                           @"baseView":self.view.vc.navigationController.view,
                           @"borderLineColor":self.view.alertBubbleTVColor,
                           @"borderLineWidth":@(1),
                           @"corner":@(5),
                           @"trangleHeight":@(8),
                           @"trangleWidth":@(8),
                           
                           @"borderInnerGap":@(10),
                           @"customeViewInnerGap":@(0),
                           
                           @"bubbleBgColor":self.view.alertBubbleTVColor,
                           @"bgColor":[UIColor clearColor],
                           @"showAroundRect":@(NO),
                           @"showLogInfo":@(NO),
                           };
    
    AlertBubbleView * abView = [[AlertBubbleView alloc] initWithDic:dic];
    
    [abView showCustomView:self.view.alertBubbleTV around:fromRect close:nil];
    
    self.view.alertBubbleView = abView;
}

- (void)showWifiVC {
    
    [UIView animateWithDuration:0.15 animations:^{
        [self.view.musicPlayboard mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view.musicPlayboard.height);
        }];
        [self.view.musicPlayboard.superview layoutIfNeeded];
    }];
    
    @weakify(self);
    BlockPVoid deallocBlock = ^(void) {
        @strongify(self);
        [UIView animateWithDuration:0.15 animations:^{
            [self.view.musicPlayboard mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(0);
            }];
            [self.view.musicPlayboard.superview layoutIfNeeded];
        }];
    };
    NSDictionary * dic = @{@"deallocBlock":deallocBlock};
    
    [self.view.vc.navigationController pushViewController:[WifiAddFileVCRouter vcWithDic:dic] animated:YES];
}

- (void)showLocalMusicVC {
    
    [self.view.vc.navigationController pushViewController:[LocalMusicVCRouter vcWithDic:nil] animated:YES];
}

#pragma mark - Interactor_EventHandler

@end
