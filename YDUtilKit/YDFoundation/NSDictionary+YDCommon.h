//
//  NSDictionary+YDCommon.h
//  YDUtilKit
//
//  Created by wangyuandong on 2021/9/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (YDCommon)

- (NSString *)jsonString: (NSString *)key;

- (NSDictionary *)jsonDict: (NSString *)key;

- (NSArray *)jsonArray: (NSString *)key;

- (NSArray *)jsonStringArray: (NSString *)key;

- (BOOL)jsonBool:(NSString *)key;

- (NSInteger)jsonInteger:(NSString *)key;

- (long long)jsonLongLong: (NSString *)key;

- (unsigned long long)jsonUnsignedLongLong:(NSString *)key;

- (double)jsonDouble: (NSString *)key;

//字典转json字符串
- (NSString *)yd_jsonString;
//json转字典
+ (NSDictionary *)yd_dictWithJsonString:(id)json;

@end

NS_ASSUME_NONNULL_END
