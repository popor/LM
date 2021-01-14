//
//  CellInfoEntity.m
//  linRunShengPi
//
//  Created by apple on 2018/3/23.
//  Copyright © 2018年 popor. All rights reserved.
//

#import "CellInfoEntity.h"

@implementation CellInfoEntity

- (id)initTag:(NSInteger)tag title:(NSString *)title subtitle:(NSString *)subtitle imageName:(NSString *)imageName {
    if (self = [super init]) {
        self.tag       = tag;
        self.title     = title;
        self.subtitle  = subtitle;
        self.imageName = imageName;
        
        self.style     = UITableViewCellStyleDefault;
        self.accessory = UITableViewCellAccessoryNone;
    }
    return self;
}

- (id)initTag:(NSInteger)tag title:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image {
    if (self = [super init]) {
        self.tag       = tag;
        self.title     = title;
        self.subtitle  = subtitle;
        self.image     = image;
        
        self.style     = UITableViewCellStyleDefault;
        self.accessory = UITableViewCellAccessoryNone;
    }
    return self;
}

- (id)initTag:(NSInteger)tag title:(NSString *)title imageName:(NSString *)imageName {
    if (self = [super init]) {
        self.tag       = tag;
        self.title     = title;
        self.imageName = imageName;
        
        self.style     = UITableViewCellStyleDefault;
        self.accessory = UITableViewCellAccessoryNone;
    }
    return self;
}

- (id)initTag:(NSInteger)tag title:(NSString *)title image:(UIImage *)image {
    if (self = [super init]) {
        self.tag       = tag;
        self.title     = title;
        self.image     = image;
        
        self.style     = UITableViewCellStyleDefault;
        self.accessory = UITableViewCellAccessoryNone;
    }
    return self;
}

- (id)initTag:(NSInteger)tag title:(NSString *)title tfText:(NSString *)tfText {
    if (self = [super init]) {
        self.tag           = tag;
        self.title         = title;
        self.tfText        = tfText;

        self.tfPlaceholder = @"";
        self.style         = UITableViewCellStyleValue1;
        self.accessory     = UITableViewCellAccessoryNone;
    }
    return self;
}

- (id)initTag:(NSInteger)tag title:(NSString *)title {
    if (self = [super init]) {
        self.tag           = tag;
        self.title         = title;
        self.tfText        = nil;
        
        self.tfPlaceholder = @"";
        self.style         = UITableViewCellStyleValue1;
        self.accessory     = UITableViewCellAccessoryNone;
    }
    return self;
}

- (id)initTag:(NSInteger)tag {
    if (self = [super init]) {
        self.tag           = tag;
        self.title         = nil;
        self.tfText        = nil;
        
        self.tfPlaceholder = @"";
        self.style         = UITableViewCellStyleValue1;
        self.accessory     = UITableViewCellAccessoryNone;
    }
    return self;
}


- (CellInfoEntity *(^)(NSInteger))cTag {
    return ^CellInfoEntity *(NSInteger value){
        self.tag = value;
        return self;
    };
}
- (CellInfoEntity *(^)(NSString *))cTitle {
    return ^CellInfoEntity *(NSString * value){
        self.title = value;
        return self;
    };
}

- (CellInfoEntity *(^)(NSMutableAttributedString *))cTitleAtt {
    return ^CellInfoEntity *(NSMutableAttributedString * value){
        self.titleAtt = value;
        return self;
    };
}

- (CellInfoEntity *(^)(NSString *))cSubtitle {
    return ^CellInfoEntity *(NSString * value){
        self.subtitle = value;
        return self;
    };
}

- (CellInfoEntity *(^)(NSString *))cImageName {
    return ^CellInfoEntity *(NSString * value){
        self.imageName = value;
        return self;
    };
}

- (CellInfoEntity *(^)(UIImage *))cImage {
    return ^CellInfoEntity *(UIImage * value){
        self.image = value;
        return self;
    };
}

- (CellInfoEntity *(^)(UITableViewCellStyle))cStyle {
    return ^CellInfoEntity *(NSInteger value){
        self.style = value;
        return self;
    };
}

- (CellInfoEntity *(^)(UITableViewCellAccessoryType))cAcc {
    return ^CellInfoEntity *(UITableViewCellAccessoryType value){
        self.accessory = value;
        return self;
    };
}

- (CellInfoEntity *(^)(NSString *))cTFText {
    return ^CellInfoEntity *(NSString * value){
        self.tfText = value;
        return self;
    };
}

- (CellInfoEntity *(^)(NSString *))cTFPlaceholder {
    return ^CellInfoEntity *(NSString * value){
        self.tfPlaceholder = value;
        return self;
    };
}

//- (CellInfoEntity *(^)(NSString *))cID {
//    return ^CellInfoEntity *(NSString * value){
//        _cID = value;
//        return self;
//    };
//}


@end
