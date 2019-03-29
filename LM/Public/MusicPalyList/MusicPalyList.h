//
//  MusicPalyList.h
//  LM
//
//  Created by apple on 2019/3/29.
//  Copyright © 2019 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicPalyList : NSObject

+ (MusicPalyList *)share;

@property (nonatomic, strong) NSMutableArray * listArray;

@end

NS_ASSUME_NONNULL_END
