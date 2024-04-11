//
//  UIApplication+YDCommon.h
//  YDUtilKit
//
//  Created by 王远东 on 2024/4/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (YDCommon)

/// for iOS 13
@property (class, nonatomic, readonly, nullable) UIWindow *keyWindow;
/// 安全区域
@property (class, nonatomic, readonly) UIEdgeInsets safeAreaInsets;

/// 打开应用设置界面，成功则返回YES，否则为NO
- (BOOL)openSettingsURL;

/// 重置APP角标数量，并且保留系统通知栏内的推送通知
/// 注意：iOS8之后，必须在使用前注册用户通知 -[UIApplication registerUserNotificationSettings:]
- (void)resetBageNumber;

/// 退出应用，有挂起动画，如果不需要动画，请直接调用exit(0)
/// @param code 退出代码
/// @param delay 为挂起动画预留的延迟时间，推荐0.5秒
- (void)exitWithCode:(int)code afterDelay:(double)delay;

/// 状态栏网络活动指示器数量，大于0显示，小于等于0隐藏
@property (nonatomic, assign) NSUInteger networkActivityIndicatorCount;

/// 设置为真自动锁屏，假则保持常亮，应用不活跃时重置为原有值
@property (nonatomic, assign) BOOL idleTimerEnabled;


@end

NS_ASSUME_NONNULL_END
