//
//  YDKeyValueObserver.h
//  YDUtilKit
//
//  Created by 王远东 on 2023/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YDKeyValueObserver : NSObject

typedef void (^YDKeyValueChangeHandler)(NSDictionary<NSKeyValueChangeKey, id> * _Nullable change, void * _Nullable context);

- (void)observe:(NSObject *)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context changeHandler:(YDKeyValueChangeHandler)changeHandler;

- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
