//
//  AlertWindowImageView.h
//  WanziTG
//
//  Created by 王凯庆 on 2016/12/22.
//  Copyright © 2016年 wanzi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ConfirmBlock_AlertWindowImageView) (BOOL isConfirm);

@interface AlertWindowImageView : UIView

- (id)initWithImage:(UIImage *)image cancelButtonTitle:(NSString *)cancelButtonTitle confireButtonTitles:(NSString *)confireButtonTitles;

- (void)showWithBlock:(ConfirmBlock_AlertWindowImageView)block;

@end
