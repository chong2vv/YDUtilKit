//
//  UIScrollView+YDCommon.m
//  app_ios
//
//  Created by 王远东 on 2019/3/17.
//  Copyright © 2019 王远东. All rights reserved.
//

#import "UIScrollView+YDCommon.h"
#import <YDUtilKit/YDFoundationCategory.h>

#define ZXToolboxSubclass @"_ZXToolbox_Subclass"

static char isScrollFreezedKey;
static char freezedViewsKey;
static char shouldRecognizeSimultaneouslyKey;

@implementation UIScrollView (YDCommon)

#pragma mark isScrollFreezed

- (void)setIsScrollFreezed:(BOOL)isScrollFreezed {
    id value = [NSNumber numberWithBool:isScrollFreezed];
    [self setAssociatedObject:&isScrollFreezedKey value:value policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
    //
    if (isScrollFreezed) {
        for (UIScrollView *view in self.freezedViews.objectEnumerator) {
            view.isScrollFreezed = NO;
        }
    }
}

- (BOOL)isScrollFreezed {
    NSNumber *value = [self getAssociatedObject:&isScrollFreezedKey];
    if (value) {
        return [value boolValue];
    }
    return NO;
}

- (void)setFreezedViews:(NSHashTable<UIScrollView *> * _Nonnull)freezedViews {
    [self setAssociatedObject:&freezedViewsKey value:freezedViews policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (NSHashTable<UIScrollView *> *)freezedViews {
    NSHashTable *obj = [self getAssociatedObject:&freezedViewsKey];
    if (obj == nil) {
        obj = [NSHashTable weakObjectsHashTable];
        [self setFreezedViews:obj];
    }
    return obj;
}

- (void)setShouldRecognizeSimultaneously:(BOOL)shouldRecognizeSimultaneously {
    Class clsA = [self class];
    NSString *strA = NSStringFromClass(clsA);
    if (![strA hasSuffix:ZXToolboxSubclass]) {
        NSString *strB = [strA stringByAppendingString:ZXToolboxSubclass];
        Class clsB = NSClassFromString(strB);
        if (clsB == nil) {
            clsB = objc_allocateClassPair(clsA, strB.UTF8String, 0);
            objc_registerClassPair(clsB);
            //
            [clsB swizzleMethod:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:) with:@selector(zx_gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)];
        }
        object_setClass(self, clsB);
    }
    //
    NSNumber *value = [NSNumber numberWithBool:shouldRecognizeSimultaneously];
    [self setAssociatedObject:&shouldRecognizeSimultaneouslyKey value:value policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (BOOL)shouldRecognizeSimultaneously {
    NSNumber *number = [self getAssociatedObject:&shouldRecognizeSimultaneouslyKey];
    if (number) {
        return [number boolValue];
    }
    return NO;
}

#pragma mark UIGestureRecognizerDelegate
// 当一个手势识别器或其他手势识别器的识别被另一个手势识别器阻塞时调用
// 返回YES，允许两者同时识别。默认实现返回NO(默认情况下不能同时识别两个手势)
// 注意：返回YES保证允许同时识别。返回NO不能保证防止同时识别，因为其他手势的委托可能返回YES
- (BOOL)zx_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.shouldRecognizeSimultaneously) {
        return YES;
    }
    return [self zx_gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
}

- (void)scrollToTop {
    [self scrollToTopAnimated:YES];
}

- (void)scrollToBottom {
    [self scrollToBottomAnimated:YES];
}

- (void)scrollToLeft {
    [self scrollToLeftAnimated:YES];
}

- (void)scrollToRight {
    [self scrollToRightAnimated:YES];
}

- (void)scrollToTopAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.y = 0 - self.contentInset.top;
    [self setContentOffset:off animated:animated];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.y = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom;
    [self setContentOffset:off animated:animated];
}

- (void)scrollToLeftAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.x = 0 - self.contentInset.left;
    [self setContentOffset:off animated:animated];
}

- (void)scrollToRightAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.x = self.contentSize.width - self.bounds.size.width + self.contentInset.right;
    [self setContentOffset:off animated:animated];
}

@end
