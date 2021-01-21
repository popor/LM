//
//  VideoPlayEntity.h
//  hywj
//
//  Created by popor on 2020/12/15.
//  Copyright © 2020 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayEntity : NSObject

@property (nonatomic, copy  ) NSString * videoName;
@property (nonatomic, copy  ) NSString * videoUrl;
@property (nonatomic, copy  ) NSString * coverUrl;

@property (nonatomic, copy  ) NSString * videoDefinitionId;
@property (nonatomic, copy  ) NSString * videoDefinitionText;

@end

NS_ASSUME_NONNULL_END
