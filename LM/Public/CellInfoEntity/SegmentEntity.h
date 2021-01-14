//
//  SegmentEntity.h
//  Ycysj
//
//  Created by 王凯庆 on 2020/2/10.
//  Copyright © 2020 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define SE_TTNS(_tag, _title, _nColor, _sColor) [[SegmentEntity alloc] initTag:_tag title:_title nColor:_nColor sColor:_sColor]
#define SE_TTNBg(_tag, _title, _nColor, _bgColor) [[SegmentEntity alloc] initTag:_tag title:_title nColor:_nColor bgColor:_bgColor]

@interface SegmentEntity : NSObject

@property (nonatomic        ) int      tag;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) UIColor  * titleNColor; // 普通文本颜色
@property (nonatomic, strong) UIColor  * titleSColor; // 选中文本颜色 // 一般不使用该颜色
@property (nonatomic, strong) UIColor  * bgColor; // 背景色

- (id)initTag:(int)tag title:(NSString *)title nColor:(UIColor *)nColor sColor:(UIColor *)sColor;
- (id)initTag:(int)tag title:(NSString *)title nColor:(UIColor *)nColor bgColor:(UIColor *)bgColor;
- (id)initTag:(int)tag title:(NSString *)title nColor:(UIColor *)nColor sColor:(UIColor *)sColor bgColor:(UIColor *)bgColor;

@end

@interface SegmentEntityTool : NSObject

@property (nonatomic, strong) NSMutableDictionary * arrayDic;
@property (nonatomic, strong) NSMutableDictionary * entityDicDic;
@property (nonatomic, strong) NSMutableDictionary * titleArrayDic;

// MARK: 工具函数
+ (instancetype)share;
+ (void)setArray:(NSArray *)array class:(Class)class;

+ (NSMutableArray *)titleArrayClass:(Class)class;
+ (NSMutableDictionary *)entityDicClass:(Class)class;

@end

NS_ASSUME_NONNULL_END
