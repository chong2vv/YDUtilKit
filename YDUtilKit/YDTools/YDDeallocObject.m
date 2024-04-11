//
//  YDDeallocObject.m
//  YDUtilKit
//
//  Created by 王远东 on 2024/4/11.
//

#import "YDDeallocObject.h"

@implementation YDDeallocObject
- (instancetype)initWithBlock:(YDDeallocBlock)block {
    self = [super init];
    if (self) {
        self.deallocBlock = block;
    }
    return self;
}

- (void)dealloc {
    _deallocBlock ? _deallocBlock() : nil;
}
@end
