//
//  AlertWindowImageView.m
//  WanziTG
//
//  Created by 王凯庆 on 2016/12/22.
//  Copyright © 2016年 wanzi. All rights reserved.
//

#import "AlertWindowImageView.h"

@interface AlertWindowImageView ()

//@property (nonatomic, strong) UIView   * alertView;

@property (nonatomic, strong) NSString * cancelButtonTitle;
@property (nonatomic, strong) NSString * confireButtonTitles;
@property (nonatomic, strong) UIImage * image;

@property (nonatomic, strong) ConfirmBlock_AlertWindowImageView confirmBlock;

@end

@implementation AlertWindowImageView

- (id)initWithImage:(UIImage *)image cancelButtonTitle:(NSString *)cancelButtonTitle confireButtonTitles:(NSString *)confireButtonTitles
{
    if (self = [super initWithFrame:PSCREEN_BOUNDS]) {
        self.backgroundColor = PRGBF(0, 0, 0, 0.3);
        self.image = image;
        self.cancelButtonTitle = cancelButtonTitle;
        self.confireButtonTitles = confireButtonTitles;
    }
    return self;
}


- (void)showWithBlock:(ConfirmBlock_AlertWindowImageView)block;
{
    self.confirmBlock = block;
    
    UIView   * alertView;
    UIImageView * imageIV;
    UIButton * cancelButton;
    UIButton * confireButton;
    
    float AVWidth  = PSCREEN_WIDTH - 88;
    float BTHeight = 49;
    float ImageWGap = 20;
    float ImageBGap = 15;
    float AVHeight = AVWidth + BTHeight - (ImageWGap - ImageBGap);
    
    float ImageW    = AVWidth - ImageWGap*2;
    float BTY       = AVHeight - BTHeight;
    
    {
        alertView = [[UIView alloc] initWithFrame:CGRectMake((PSCREEN_WIDTH - AVWidth)/2, (PSCREEN_HEIGHT - AVHeight)/2, AVWidth, AVHeight)];
        alertView.backgroundColor = [UIColor whiteColor];
        alertView.layer.cornerRadius = 4;
        alertView.clipsToBounds = YES;
        
        [self addSubview:alertView];
    }
    {
        imageIV = [[UIImageView alloc] initWithFrame:CGRectMake(ImageWGap, ImageWGap, ImageW, ImageW)];
        imageIV.image = self.image;
        imageIV.contentMode = UIViewContentModeScaleAspectFit;
        self.image = nil;
        imageIV.layer.borderColor = PRGBF(0, 0, 0, 0.3).CGColor;
        imageIV.layer.borderWidth = 1;
        
        [alertView addSubview:imageIV];
    }
    
    {
        cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(0, BTY, AVWidth/2, BTHeight);
        [cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
        [cancelButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        //[cancelButton setBackgroundColor:[UIColor redColor]];
        
        [cancelButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        [alertView addSubview:cancelButton];
    }
    {
        confireButton = [UIButton buttonWithType:UIButtonTypeCustom];
        confireButton.frame = CGRectMake(AVWidth/2, BTY, AVWidth/2, BTHeight);
        [confireButton setTitle:self.confireButtonTitles forState:UIControlStateNormal];
        [confireButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        //[confireButton setBackgroundColor:[UIColor greenColor]];
        
        [confireButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
        [alertView addSubview:confireButton];
    }
    {
        UIImageView * oneIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, BTY, alertView.width, 0.5)];
        oneIV.backgroundColor = UIColor.grayColor;
        
        [alertView addSubview:oneIV];
    }
    {
        UIImageView * oneIV = [[UIImageView alloc] initWithFrame:CGRectMake(alertView.width/2, BTY, 0.5, BTHeight)];
        oneIV.backgroundColor = UIColor.grayColor;
        
        [alertView addSubview:oneIV];
    }
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:self];
}


- (void)closeAction {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.confirmBlock) {
            self.confirmBlock(NO);
        }
    }];
}

- (void)confirmAction {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.confirmBlock) {
            self.confirmBlock(YES);
        }
    }];
}


@end


//- (id)initWithTitle:(NSString *)title message:(NSString *)message image:(UIImage *)image cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
//{
//    if (self = [super init]) {
//        if (otherButtonTitles) {
//
//            NSString * eachButtonTitles;
//
//            va_list argumentList;//va_list 是一个字符指针，可以理解为指向当前参数的一个指针，取参必须通过这个指针进行
//            NSLog(@"otherButtonTitles :%@", otherButtonTitles);
//            //[self addButtonWithTitle:otherButtonTitles];
//
//            va_start(argumentList, otherButtonTitles);// 然后应该对argumentList进行初始化，让它指向可变参数表里面的第一个参数，这是通过 va_start 来实现的，第一个参数是argumentList本身，第二个参数是在变参表前面紧挨着的一个变量,即“...”之前的那个参数
//
//            while ((eachButtonTitles = va_arg(argumentList, id))) {//然后是获取参数，调用va_arg，它的第一个参数是argumentList，第二个参数是要获取的参数的指定类型，然后返回这个指定类型的值，并且把argumentList的位置指向变参表的下一个变量位置
//
//                NSLog(@"otherButtonTitles :%@", eachButtonTitles);
//            }
//            va_end(argumentList);//置空argumentList//获取所有的参数之后，我们有必要将这个argumentList指针关掉，以免发生危险，方法是调用 va_end，它使输入的参数argumentList置为 NULL，应该养成获取完参数表之后关闭指针的习惯。说白了，就是让我们的程序具有健壮性。通常va_start和va_end是成对出现。
//        }
//    }
//    return self;
//}
