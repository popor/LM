//
//  LrcListEntity.h
//  LM
//
//  Created by popor on 2020/10/13.
//  Copyright © 2020 popor. All rights reserved.
//

#import "PoporJsonModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LrcListUnitEntity;
@interface LrcListUnitEntity : PoporJsonModel

//@property (nonatomic, copy  ) NSString * aid;//": 2848529,
//@property (nonatomic, copy  ) NSString * artist_id;//": 2,
//@property (nonatomic, copy  ) NSString * sid;//": 3443588,
//@property (nonatomic, copy  ) NSString * song;//": "海阔天空"

@property (nonatomic, copy  ) NSString * lrc;//": "http://s.gecimi.com/lrc/344/34435/3443588.lrc",

@end


@interface LrcListEntity : PoporJsonModel

@property (nonatomic, copy  ) NSArray<LrcListUnitEntity> * result;

@end

NS_ASSUME_NONNULL_END
