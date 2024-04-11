//
//  NSObject+YDCommon.m
//  YDUtilKit
//
//  Created by 王远东 on 2022/8/17.
//

#import "NSObject+YDCommon.h"
#import <objc/runtime.h>
#import "YDDeallocObject.h"

@implementation NSObject (YDCommon)

- (BOOL)isEmpty {
    if (self == nil ||
        self == [NSNull null] ||
        [@"" isEqualToString:[self description]]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isEmpty:(NSObject *)aObj {
    if (aObj == nil ||
        aObj == [NSNull null] ||
        [@"" isEqualToString:[aObj description]]) {
        return YES;
    }
    return NO;
}

+ (void)swizzleClassMethod:(SEL)originalSelector with:(SEL)swizzledSelector {
    // When swizzling a class method, use the following:
    // Class class = object_getClass((id)self);
    // ...
    // Method originalMethod = class_getClassMethod(class, originalSelector);
    // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    Class class = object_getClass((id)self);
    
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)swizzleMethod:(SEL)originalSelector with:(SEL)swizzledSelector {
    Class class = self;
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)swizzleMethod:(SEL)originalSelector with:(SEL)swizzledSelector class:(Class)originalClass {
    Class swizzledClass = [self class];
    
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    Method replacedMethod = class_getInstanceMethod(swizzledClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
    
    if (originalMethod) {
        BOOL didAddMethod = class_addMethod(originalClass,
                                            swizzledSelector,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            Method exchangeMethod = class_getInstanceMethod(originalClass, swizzledSelector);
            method_exchangeImplementations(originalMethod, exchangeMethod);
        }
    } else {
        BOOL didAddMethod = class_addMethod(originalClass,
                                            originalSelector,
                                            method_getImplementation(replacedMethod),
                                            method_getTypeEncoding(replacedMethod));
        if (didAddMethod) {
            // Nothing
        }
    }
}

- (void)setAssociatedObject:(const void *)key value:(id)value policy:(objc_AssociationPolicy)policy {
    if (policy == OBJC_ASSOCIATION_ASSIGN) {
        YDDeallocObject *obj = [[YDDeallocObject alloc] initWithBlock:^{
            objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_ASSIGN);
        }];
        objc_setAssociatedObject(value, (__bridge const void *)(obj.deallocBlock), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    objc_setAssociatedObject(self, key, value, policy);
}

- (id)getAssociatedObject:(const void *)key {
    return objc_getAssociatedObject(self, key);
}
@end
