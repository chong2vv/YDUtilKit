//
//  YDKeyValueObserver.m
//  YDUtilKit
//
//  Created by 王远东 on 2023/10/30.
//

#import "YDKeyValueObserver.h"

@interface YDKeyValueObserver ()
@property (nonatomic, weak) NSObject *object;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, assign) void *context;
@property (nonatomic, copy) YDKeyValueChangeHandler changeHandler;
@end

@implementation YDKeyValueObserver


- (void)observe:(nonnull NSObject *)object keyPath:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context changeHandler:(nonnull YDKeyValueChangeHandler)changeHandler {
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {
    if (object == self.object && [keyPath isEqualToString:self.keyPath]) {
        if (self.changeHandler) {
            self.changeHandler(change, context);
        }
    }
}


- (void)invalidate {
    [self.object removeObserver:self forKeyPath:self.keyPath context:self.context];
    self.object = nil;
    self.keyPath = nil;
    self.context = NULL;
    self.changeHandler = nil;
}

@end
