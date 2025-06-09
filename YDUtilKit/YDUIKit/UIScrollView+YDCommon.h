//
//  UIScrollView+YDCommon.h
//  app_ios
//
//  Created by 王远东 on 2019/3/17.
//  Copyright © 2019 王远东. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (YDCommon)

/// @brief 冻结滚动
/// @attention 注意：设置为 true 时会解冻 freezedViews 内的视图
@property (nonatomic, assign) BOOL isScrollFreezed;
/// @brief 当本视图冻结滚动时，解冻其它冻结的视图
@property (nonatomic, readonly, nonnull) NSHashTable<UIScrollView *> *freezedViews;
/// @brief 冻结滚动的底层视图（父视图），需要同时识别多个手势，默认为 NO。
/// @discussion The super view needs recognize multiple gestures simultaneously.
@property (nonatomic, assign) BOOL shouldRecognizeSimultaneously;

/*=========== 默认开启动画 ===========*/
/**
 滑动到顶部
 */
- (void)scrollToTop;

/**
 滑动到底部
 */
- (void)scrollToBottom;

/**
 滑动到左侧
 */
- (void)scrollToLeft;

/**
 滑动到右侧
 */
- (void)scrollToRight;

/**
 滑动到顶部
 
 @param animated  是否开启动画
 */
- (void)scrollToTopAnimated:(BOOL)animated;

/**
 滑动到底部
 
 @param animated  是否开启动画
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

/**
 滑动到左侧
 
 @param animated  是否开启动画
 */
- (void)scrollToLeftAnimated:(BOOL)animated;

/**
 滑动到右侧
 
 @param animated  是否开启动画
 */
- (void)scrollToRightAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
