//
//  UIView+YDCommon.h
//  app_ios
//
//  Created by 王远东 on 2019/3/17.
//  Copyright © 2019 王远东. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (YDCommon)

@property (nonatomic) CGFloat left;        ///< frame.origin.x.
@property (nonatomic) CGFloat top;         ///< frame.origin.y
@property (nonatomic) CGFloat right;       ///< frame.origin.x + frame.size.width
@property (nonatomic) CGFloat bottom;      ///< frame.origin.y + frame.size.height
@property (nonatomic) CGFloat width;       ///< frame.size.width.
@property (nonatomic) CGFloat height;      ///< frame.size.height.
@property (nonatomic) CGFloat centerX;     ///< center.x
@property (nonatomic) CGFloat centerY;     ///< center.y
@property (nonatomic) CGPoint origin;      ///< frame.origin.
@property (nonatomic) CGSize  size;        ///< frame.size.
/**
 返回view所在的ViewController
 */
@property (nullable, nonatomic, readonly) UIViewController *viewController;

/**
 移除所有的子view
 
 @ps: 不要在 drawRect: 方法中调用这个方法
 */
- (void)removeAllSubviews;


@end

NS_ASSUME_NONNULL_END
