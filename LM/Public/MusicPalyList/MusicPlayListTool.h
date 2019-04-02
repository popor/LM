//
//  MusicPlayListTool.h
//  LM
//
//  Created by apple on 2019/4/1.
//  Copyright © 2019 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MusicPlayList.h"

#define MpltShare [MusicPlayListTool share]

NS_ASSUME_NONNULL_BEGIN

@interface MusicPlayListTool : NSObject


+ (MusicPlayListTool *)share;

@property (nonatomic, strong) MusicPlayList * list;

- (void)addListName:(NSString *)name;

- (void)update;

@end

NS_ASSUME_NONNULL_END
