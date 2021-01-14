//
//  CellInfoEntity.h
//  linRunShengPi
//
//  Created by apple on 2018/3/23.
//  Copyright © 2018年 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

static UITableViewCellStyle CStyleDefault               = UITableViewCellStyleDefault;
static UITableViewCellStyle CStyleValue1                = UITableViewCellStyleValue1;
static UITableViewCellStyle CStyleValue2                = UITableViewCellStyleValue2;
static UITableViewCellStyle CStyleSubtitle              = UITableViewCellStyleSubtitle;

//----------
static UITableViewCellAccessoryType AccNone             = UITableViewCellAccessoryNone;
static UITableViewCellAccessoryType AccIndicator        = UITableViewCellAccessoryDisclosureIndicator;
static UITableViewCellAccessoryType AccDisclosureButton = UITableViewCellAccessoryDetailDisclosureButton;
static UITableViewCellAccessoryType AccCheckmark        = UITableViewCellAccessoryCheckmark;
static UITableViewCellAccessoryType AccDetailButton     = UITableViewCellAccessoryDetailButton;

#define CIEnew [CellInfoEntity new]

// 0.普通宏定义
#define CIE_TTSIn(tag, title, subtitle, imageName) [[CellInfoEntity alloc] initTag:tag t##itle:title s##ubtitle:subtitle i##mageName:imageName]
#define CIE_TTSI(tag, title, subtitle, image)      [[CellInfoEntity alloc] initTag:tag t##itle:title s##ubtitle:subtitle i##mage:image]

#define CIE_TTIn(tag, title, imageName)  [[CellInfoEntity alloc] initTag:tag t##itle:title i##mageName:imageName]
#define CIE_TTI(tag, title, image)       [[CellInfoEntity alloc] initTag:tag t##itle:title i##mage:image]

#define CIE_TTT(tag, title, tfText)      [[CellInfoEntity alloc] initTag:tag t##itle:title t##fText:tfText]
#define CIE_TT(tag, title)               [[CellInfoEntity alloc] initTag:tag t##itle:title]
#define CIE_T(tag)                       [[CellInfoEntity alloc] initTag:tag]


@interface CellInfoEntity : NSObject

@property (nonatomic        ) NSInteger  tag;
//@property (nonatomic, strong) NSString * cID;

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSMutableAttributedString * titleAtt;
@property (nonatomic, strong) NSString * subtitle;
@property (nonatomic, strong) NSString * imageName;
@property (nonatomic, strong) UIImage  * image;

@property (nonatomic, strong) NSString * tfText;
@property (nonatomic, strong) NSString * tfPlaceholder;

@property (nonatomic        ) UITableViewCellStyle            style;
@property (nonatomic        ) UITableViewCellAccessoryType    accessory;

@property (nonatomic, weak  ) NSMutableArray * weakArray1;
@property (nonatomic, strong) NSMutableArray * strongArray1;

@property (nonatomic, weak  ) id data1;
@property (nonatomic, weak  ) id data2;
@property (nonatomic, weak  ) id data3;
@property (nonatomic, weak  ) id data4;
@property (nonatomic, weak  ) id data5;

// 1.默认初始化
- (id)initTag:(NSInteger)tag title:(NSString *)title subtitle:(NSString *)subtitle imageName:(NSString *)imageName;
- (id)initTag:(NSInteger)tag title:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image;

- (id)initTag:(NSInteger)tag title:(NSString *)title imageName:(NSString *)imageName;
- (id)initTag:(NSInteger)tag title:(NSString *)title image:(UIImage *)image;

- (id)initTag:(NSInteger)tag title:(NSString *)title tfText:(NSString *)tfText;
- (id)initTag:(NSInteger)tag title:(NSString *)title;
- (id)initTag:(NSInteger)tag;


// 2.链式结构
- (CellInfoEntity *(^)(NSInteger ))cTag;
- (CellInfoEntity *(^)(NSString *))cTitle;
- (CellInfoEntity *(^)(NSMutableAttributedString *))cTitleAtt;
- (CellInfoEntity *(^)(NSString *))cSubtitle;
- (CellInfoEntity *(^)(NSString *))cImageName;
- (CellInfoEntity *(^)(UIImage  *))cImage;
- (CellInfoEntity *(^)(NSString *))cTFText;
- (CellInfoEntity *(^)(NSString *))cTFPlaceholder;
//- (CellInfoEntity *(^)(NSString *))ID;

- (CellInfoEntity *(^)(UITableViewCellStyle))cStyle;
- (CellInfoEntity *(^)(UITableViewCellAccessoryType))cAcc;

// 3.不初始化,全局更改参数的方法.


@end
