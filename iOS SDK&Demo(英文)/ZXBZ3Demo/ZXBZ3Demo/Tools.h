//
//  Tools.h
//  ZXBZ3Demo
//
//  Created by 刘清 on 2018/12/15.
//  Copyright © 2018 WIIKK. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WeakSelf(type) __weak typeof(type) weak##type = type

#define KScreenWidth ([[UIScreen mainScreen]bounds].size.width)
#define KScreenHeight ([[UIScreen mainScreen]bounds].size.height)
#define kStatusBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define isiPhoneX (kStatusBarHeight>20.f?YES:NO)
#define kNavBarHeight (isiPhoneX?88.f:64.f)

@interface Tools : NSObject

/** 截取URL中的参数 */
+ (NSMutableDictionary *)getURLParameters:(NSString *)urlStr;


@end
