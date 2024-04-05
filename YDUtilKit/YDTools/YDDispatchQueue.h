//
//  YDDispatchQueue.h
//  YDUtilKit
//
//  Created by 王远东 on 2024/4/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YDDispatchQueue : NSObject

/// 主队列单例
+ (instancetype)main;

/// 全局队列单例
+ (instancetype)global;

/// 初始化自定义队列
/// @param queue 自定义队列
- (instancetype)initWithQueue:(dispatch_queue_t)queue;

/// 异步延迟执行事件
/// @param event 事件名称
/// @param delayInSeconds 延迟时间，秒
/// @param execute 执行回调
- (void)asyncAfter:(NSString *)event deadline:(NSTimeInterval)delayInSeconds execute:(void(^)(NSString *event))execute;

/// 取消延迟执行事件
/// @param event 事件名称
- (void)cancelAfter:(NSString *)event;

@end

NS_ASSUME_NONNULL_END
