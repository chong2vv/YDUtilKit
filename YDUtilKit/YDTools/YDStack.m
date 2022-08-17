//
//  YDStack.m
//  YDUtilKit
//
//  Created by 王远东 on 2022/8/16.
//

#import "YDStack.h"

@interface YDStack ()

@property (nonatomic, strong)NSMutableArray *stackArray;

@end

@implementation YDStack


- (NSMutableArray *)stackArray {
    if (!_stackArray) {
        _stackArray = [NSMutableArray new];
    }
    return _stackArray;
}

- (void)push:(id)obj {
    if (obj == nil) {
        return;
    }
    [self.stackArray addObject:obj];
}

- (id)popObj {
    if ([self isEmpty]) {
        return nil;
    } else {
        id lastObject = self.stackArray.lastObject;
        [self.stackArray removeLastObject];
        return lastObject;
    }
}

-(id)topObj {
    if ([self isEmpty]) {
        return nil;
    } else {
        return self.stackArray.lastObject;
    }
}

- (BOOL)isEmpty {
    return !self.stackArray.count;
}

- (NSInteger)stackLength {
    return self.stackArray.count;
}

#pragma mark - 遍历

// 从栈底开始遍历
-(void)enumerateObjectsFromBottom:(StackBlock)block {
    [self.stackArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block ? block(obj) : nil;
    }];
}

// 从顶部开始遍历
-(void)enumerateObjectsFromtop:(StackBlock)block {
    [self.stackArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block ? block(obj) : nil;
    }];
}

// 所有元素出栈，一边出栈一边返回元素
-(void)enumerateObjectsPopStack:(StackBlock)block {
    __weak typeof(self) weakSelf = self;
    NSUInteger count = self.stackArray.count;
    for (NSUInteger i = count; i > 0; i --) {
        if (block) {
            block(weakSelf.stackArray.lastObject);
            [self.stackArray removeLastObject];
        }
    }
}

#pragma mark - remove

-(void)removeAllObjects {
    [self.stackArray removeAllObjects];
}
@end
