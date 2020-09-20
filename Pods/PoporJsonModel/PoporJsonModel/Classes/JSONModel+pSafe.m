//
//  JSONModel+pSafe.m
//  JSONModel
//
//  Created by apple on 2019/11/1.
//

#import "JSONModel+pSafe.h"

#import <PoporFoundation/NSObject+pSwizzling.h>
#import "PoporJsonModelTool.h"

@implementation JSONModel (pSafe)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 初始化
        [objc_getClass("JSONModel") methodSwizzlingWithOriginalSelector:@selector(initWithDictionary:error:)  bySwizzledSelector:@selector(safeInitWithDictionary:error:)];
    });
}

- (instancetype)safeInitWithDictionary:(NSDictionary *)dict error:(NSError **)err {
    id entity;
    if (err) {
        entity = [self safeInitWithDictionary:dict error:err];
    }else{
        NSError * error;
        entity = [self safeInitWithDictionary:dict error:&error];
        if (error) {
            PoporJsonModelTool * tool = [PoporJsonModelTool share];
            if (tool.blockError) {
                tool.blockError(error);
            } else {
                NSLog(@"PoporJsonModel ERROR: %@", error.userInfo[@"kJSONModelTypeMismatch"]);
            }
        }
    }
    
    return entity;
}


@end
