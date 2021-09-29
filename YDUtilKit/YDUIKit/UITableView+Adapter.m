//
//  UITableView+Adapter.m
//  ArtChat
//
//  Created by weijingyun on 2017/9/21.
//

#import "UITableView+Adapter.h"
#import <objc/runtime.h>

@implementation UITableView (Adapter)

+ (void)load {
    swizzling_exchangeMethod([self class], @selector(initWithFrame:style:), @selector(swizz_initWithFrame:style:));
}

- (instancetype)swizz_initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    UITableView *table = [self swizz_initWithFrame:frame style:style];
    table.sectionHeaderHeight = 0.;
    table.sectionFooterHeight = 0.;
    table.estimatedRowHeight = 0.;
    table.estimatedSectionFooterHeight = 0.;
    table.estimatedSectionHeaderHeight = 0.;
    
    if (@available(iOS 11.0, *)) {
        table.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return table;
}

static inline void swizzling_exchangeMethod(Class clazz ,SEL originalSelector, SEL swizzledSelector){
    Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector);
    
    BOOL success = class_addMethod(clazz, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(clazz, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


@end
