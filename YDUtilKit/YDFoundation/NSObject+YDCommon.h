//
//  NSObject+YDCommon.h
//  YDUtilKit
//
//  Created by 王远东 on 2022/8/17.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (YDCommon)

//对象自身添加是否为空判断
- (BOOL)isEmpty;

//NSObject支持提供检测是否为空
+ (BOOL)isEmpty:(NSObject*)aObj;

/**
 替换类方法

 @param originalSelector 原始方法
 @param swizzledSelector 替换方法
 */
+ (void)swizzleClassMethod:(SEL)originalSelector with:(SEL)swizzledSelector;

/**
 替换实例方法

 @param originalSelector 原始方法
 @param swizzledSelector 替换方法
 */
+ (void)swizzleMethod:(SEL)originalSelector with:(SEL)swizzledSelector;

/**
 替换代理方法，这里需要注意两点
 1.如果代理实现了originalSelector，直接使用swizzledSelector进行替换，
   需要在swizzledSelector内再次调用swizzledSelector方法；
 2.如果代理没有实现originalSelector，则需要self实现originalSelector方法，
   originalSelector内部不需要调用originalSelector方法。

 @param originalSelector 原始方法
 @param swizzledSelector 替换方法
 @param originalClass 原始Class
 */
- (void)swizzleMethod:(SEL)originalSelector with:(SEL)swizzledSelector class:(Class)originalClass;

/// Sets an associated value for a given object using a given key and association policy.
/// @param key The key for the association.
/// @param value The value to associate with the key key for object. Pass nil to clear an existing association.
/// @param policy The policy for the association. For possible values, see objc_AssociationPolicy.
/// @see objc_AssociationPolicy
- (void)setAssociatedObject:(nonnull const void *)key
                      value:(nullable id)value
                     policy:(objc_AssociationPolicy)policy;

/// Returns the value associated with a given object for a given key.
/// @param key The key for the association.
- (nullable id)getAssociatedObject:(nullable const void *)key;
@end

NS_ASSUME_NONNULL_END
