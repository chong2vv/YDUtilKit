//
//  NSArray+YDCommon.h
//  app_ios
//
//  Created by 王远东 on 2019/3/17.
//  Copyright © 2019 王远东. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//__covariant - 协变性，子类型可以强转到父类型（里氏替换原则）
@interface NSArray<__covariant ObjectType>  (YDCommon)

/**
 获取index数据，但是数组越界为空不会抛出异常
 */
- (nullable ObjectType)objectOrNilAtIndex:(NSUInteger)index;

/**
 json转码
 */
- (nullable NSString *)jsonStringEncoded;

/**
 json转码
 */
- (nullable NSString *)jsonPrettyStringEncoded;

// 根据string的内容返回数组
+ (NSArray<NSString *> *)arrayFromSeparatedString:(NSString *)string sepString:(NSString *)sepString;

@end

@interface NSMutableArray<ObjectType> (YDCommon)

/**
 删除第一条数据
 */
- (void)removeFirstObject;

/**
 删除最后一条数据
 */
- (void)removeLastObject;

/**
 批量添加objects
 */
- (void)insertObjects:(NSArray *)objects atIndex:(NSUInteger)index;

/**
 翻转数组
 */
- (void)reverse;

/**
 随机排序
 */
- (void)shuffle;

@end

NS_ASSUME_NONNULL_END
