//
//  UIView+YDWhenTappedBlocks.h
//  YDUtilKit
//
//  Created by wangyuandong on 2021/9/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^YDWhenTappedBlock)(void);

@interface UIView (YDWhenTappedBlocks)<UIGestureRecognizerDelegate>

- (void)whenTapped:(YDWhenTappedBlock)block;
- (void)whenDoubleTapped:(YDWhenTappedBlock)block;
- (void)whenFiveTapped:(YDWhenTappedBlock)block;
- (void)whenTwoFingerTapped:(YDWhenTappedBlock)block;
- (void)whenTouchedDown:(YDWhenTappedBlock)block;
- (void)whenTouchedUp:(YDWhenTappedBlock)block;

// 单击 需设置 whenTapped
- (void)viewWasTapped;

// 提供给画室的 head 点击响应使用
- (void)viewWasTappedPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
