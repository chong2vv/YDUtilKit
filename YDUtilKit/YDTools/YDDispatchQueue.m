//
//  YDDispatchQueue.m
//  YDUtilKit
//
//  Created by 王远东 on 2024/4/3.
//

#import "YDDispatchQueue.h"

@interface YDDispatchQueue ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *events;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation YDDispatchQueue


+ (instancetype)main {
    static YDDispatchQueue *main;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        main = [[YDDispatchQueue alloc] initWithQueue:dispatch_get_main_queue()];
    });
    return main;
}

+ (instancetype)global {
    static YDDispatchQueue *global;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        global = [[YDDispatchQueue alloc] initWithQueue:dispatch_get_global_queue(0, 0)];
    });
    return global;
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue {
    self = [super init];
    if (self) {
        self.queue = queue;
        self.events = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)asyncAfter:(NSString *)event deadline:(NSTimeInterval)delayInSeconds execute:(void(^)(NSString *event))execute {
    NSString *uuid = [NSUUID UUID].UUIDString;
    self.events[event] = uuid;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), self.queue, ^{
        if ([self.events[event] isEqualToString:uuid]) {
            if (execute) {
                execute(event);
            }
        }
    });
}

- (void)cancelAfter:(NSString *)event {
    [self.events removeObjectForKey:event];
}
@end
