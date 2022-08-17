//
//  NSObject+YDCommon.h
//  YDUtilKit
//
//  Created by 王远东 on 2022/8/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (YDCommon)

//对象自身添加是否为空判断
- (BOOL)isEmpty;

//NSObject支持提供检测是否为空
+ (BOOL)isEmpty:(NSObject*)aObj;

@end

NS_ASSUME_NONNULL_END
