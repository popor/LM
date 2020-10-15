//
//  LrcKugouListEntity.h
//  LM
//
//  Created by popor on 2020/10/15.
//  Copyright © 2020 popor. All rights reserved.
//

#import "PoporJsonModel.h"
#import "LrcKugouListEntity.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LrcKugouListUnitEntity;
@interface LrcKugouListUnitEntity : PoporJsonModel

@property (nonatomic, copy  ) NSString * id;
@property (nonatomic, copy  ) NSString * accesskey;

@end

@interface LrcKugouListEntity : PoporJsonModel

@property (nonatomic, copy  ) NSArray<LrcKugouListUnitEntity> * lrcArray;

@end

NS_ASSUME_NONNULL_END
