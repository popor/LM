//
//  PoporJsonModelTool.h
//  JSONModel
//
//  Created by apple on 2019/11/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^BlockPoporJsonModel) (NSError * error);

@interface PoporJsonModelTool : NSObject

+ (instancetype)share;

@property (nonatomic, copy  ) BlockPoporJsonModel blockError;

@end

NS_ASSUME_NONNULL_END
