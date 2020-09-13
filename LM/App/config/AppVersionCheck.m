//
//  AppVersionCheck.m
//  LM
//
//  Created by apple on 2019/4/9.
//  Copyright © 2019 popor. All rights reserved.
//

#import "AppVersionCheck.h"
#import <PoporAFN/PoporAFN.h>
#import <YYModel/YYModel.h>

@implementation AppVersionEntity

@end

@implementation AppVersionCheck

// 弹出警告框
+ (void)oneAlertCheckVersionAtVC:(UIViewController *)vc finish:(BlockPBool _Nonnull)finish {
    //NSString * url = @"https://github.com/popor/LM/blob/master/LM/version.json";
    NSString * url = @"https://raw.githubusercontent.com/popor/LM/master/LM/version.json";
    
    @weakify(vc);
    [PoporAFNTool title:@"访问最新版本号" url:url method:PoporMethodGet parameters:nil success:^(NSString * _Nonnull url, NSData * _Nullable data, NSDictionary * _Nullable dic) {
        @strongify(vc);
        
        AppVersionEntity * entity = [AppVersionEntity yy_modelWithDictionary:dic];
        if ([entity.version isEqualToString:[UIDevice getAppVersion_short]]) {
            AlertToastTitle(@"已经是最新版本");
            finish(NO);
        }else{
            finish(YES);
            [AppVersionCheck alertEntity:entity vc:vc];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        AlertToastTitle(error.localizedDescription);
        finish(NO);
    }];
}

// 每天只自动弹出一次警告框
+ (void)autoAlertCheckVersionAtVc:(UIViewController *)vc finish:(BlockPBool _Nonnull)finish  {
    NSString * currentDate = [NSDate stringFromNow:@"yyyy-MM-dd"];
    BOOL needShow;
    if ([currentDate isEqualToString:[self getAppCheckDate]]) {
        needShow = NO;
    }else{
        needShow = YES;
        [self saveAppCheckDate:currentDate];
    }
    //NSString * url = @"https://github.com/popor/LM/blob/master/LM/version.json";
    NSString * url = @"https://raw.githubusercontent.com/popor/LM/master/LM/version.json";
    
    @weakify(vc);
    [PoporAFNTool title:@"访问最新版本号" url:url method:PoporMethodGet parameters:nil success:^(NSString * _Nonnull url, NSData * _Nullable data, NSDictionary * _Nullable dic) {
        @strongify(vc);
        
        AppVersionEntity * entity = [AppVersionEntity yy_modelWithDictionary:dic];
        if ([entity.version isEqualToString:[UIDevice getAppVersion_short]]) {
            finish(NO);
        }else{
            finish(YES);
            if (needShow) {
                [AppVersionCheck alertEntity:entity vc:vc];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        finish(NO);
    }];
}

+ (void)alertEntity:(AppVersionEntity *)entity vc:(UIViewController *)vc {
    UIAlertController * oneAC = [UIAlertController alertControllerWithTitle:@"更新" message:[NSString stringWithFormat:@"最新版本是: %@，是否下载更新？", entity.version] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:entity.downloadUrl]];
    }];
    
    [oneAC addAction:cancleAction];
    [oneAC addAction:okAction];
    
    [vc presentViewController:oneAC animated:YES completion:nil];
}

+ (void)saveAppCheckDate:(NSString *)checkDate {
    [[NSUserDefaults standardUserDefaults] setObject:checkDate forKey:@"AppCheckDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getAppCheckDate {
    NSString * info = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppCheckDate"];
    return info;
}


@end
