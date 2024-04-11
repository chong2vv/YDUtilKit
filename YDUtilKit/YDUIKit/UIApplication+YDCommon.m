//
//  UIApplication+YDCommon.m
//  YDUtilKit
//
//  Created by 王远东 on 2024/4/11.
//

#import "UIApplication+YDCommon.h"
#import "NSObject+YDCommon.h"

static char networkActivityIndicatorCountKey;
static char idleTimerDisabledSavedKey;
static char willResignActiveObserverKey;
static char didEnterBackgroundObserverKey;
static char willEnterForegroundObserverKey;
static char didBecomeActiveObserverKey;
static char idleTimerEnabledKey;

@interface UIApplication ()
@property (nonatomic, assign) NSNumber *idleTimerDisabledSaved;
@property (nonatomic, strong) id willResignActiveObserver;
@property (nonatomic, strong) id didEnterBackgroundObserver;
@property (nonatomic, strong) id willEnterForegroundObserver;
@property (nonatomic, strong) id didBecomeActiveObserver;

@end


@implementation UIApplication (YDCommon)

+ (UIWindow *)keyWindow {
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindow *win in [UIApplication sharedApplication].windows) {
            if (win.isKeyWindow) {
                window = win;
                break;
            }
        }
    } else {
        window = [UIApplication sharedApplication].keyWindow;
    }
    return window;
}

+ (UIEdgeInsets)safeAreaInsets {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    UIViewController *vc = UIApplication.keyWindow.rootViewController;
    if (vc) {
        if (@available(iOS 11.0, *)) {
            insets = vc.view.safeAreaInsets;
        } else {
            insets.top = vc.topLayoutGuide.length;
            insets.bottom = vc.bottomLayoutGuide.length;
        }
    }
    return insets;
}

- (BOOL)openSettingsURL {
    NSURL *url = nil;
    if(@available(iOS 8.0, *)) {
        url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"prefs:root==%@", [NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"]]];
    }
    if([self canOpenURL:url]) {
        if(@available(iOS 10.0, *)) {
            [self openURL:url options:@{} completionHandler:^(BOOL success) {
                //return success;
            }];
            return YES;
        } else {
            return [self openURL:url];
        }
    }
    return NO;
}

- (void)resetBageNumber {
    if(@available(iOS 11.0, *)) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = -1;
    } else {
        UILocalNotification *clearEpisodeNotification = [[UILocalNotification alloc] init];
        clearEpisodeNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:(0.3)];
        clearEpisodeNotification.timeZone = [NSTimeZone defaultTimeZone];
        clearEpisodeNotification.applicationIconBadgeNumber = -1;
        [[UIApplication sharedApplication] scheduleLocalNotification:clearEpisodeNotification];
    }
}

- (void)exitWithCode:(int)code afterDelay:(double)delay {
    [[UIApplication sharedApplication] performSelector:@selector(suspend)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0);
    });
}

#pragma mark NetworkActivityIndicator

- (void)setNetworkActivityIndicatorCount:(NSUInteger)networkActivityIndicatorCount {
    [self setAssociatedObject:&networkActivityIndicatorCountKey value:@(networkActivityIndicatorCount) policy:OBJC_ASSOCIATION_RETAIN];
    self.networkActivityIndicatorVisible = networkActivityIndicatorCount > 0;
}

- (NSUInteger)networkActivityIndicatorCount {
    NSNumber *number = [self getAssociatedObject:&networkActivityIndicatorCountKey];
    return [number integerValue];
}

#pragma mark IdleTimer

- (NSNumber *)idleTimerDisabledSaved {
    return [self getAssociatedObject:&idleTimerDisabledSavedKey];
}

- (void)setIdleTimerDisabledSaved:(NSNumber *)idleTimerDisabledSaved {
    [self setAssociatedObject:&idleTimerDisabledSavedKey value:idleTimerDisabledSaved policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (id)willResignActiveObserver {
    return [self getAssociatedObject:&willResignActiveObserverKey];
}

- (void)setWillResignActiveObserver:(id)willResignActiveObserver {
    [self setAssociatedObject:&willResignActiveObserverKey value:willResignActiveObserver policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (id)didEnterBackgroundObserver {
    return [self getAssociatedObject:&didEnterBackgroundObserverKey];
}

- (void)setDidEnterBackgroundObserver:(id)didEnterBackgroundObserver {
    [self setAssociatedObject:&didEnterBackgroundObserverKey value:didEnterBackgroundObserver policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (id)willEnterForegroundObserver {
    return [self getAssociatedObject:&willEnterForegroundObserverKey];
}

- (void)setWillEnterForegroundObserver:(id)willEnterForegroundObserver {
    [self setAssociatedObject:&willEnterForegroundObserverKey value:willEnterForegroundObserver policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (id)didBecomeActiveObserver {
    return [self getAssociatedObject:&didBecomeActiveObserverKey];
}

- (void)setDidBecomeActiveObserver:(id)didBecomeActiveObserver {
    [self setAssociatedObject:&didBecomeActiveObserverKey value:didBecomeActiveObserver policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (BOOL)idleTimerEnabled {
    NSNumber *number = [self getAssociatedObject:&idleTimerEnabledKey];
    return [number boolValue];
}

- (void)setIdleTimerEnabled:(BOOL)idleTimerEnabled {
    if (self.idleTimerDisabledSaved == nil) {
        self.idleTimerDisabledSaved = @(self.idleTimerDisabled);
    }
    //
    [self setAssociatedObject:&idleTimerEnabledKey value:@(idleTimerEnabled) policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
    self.idleTimerDisabled = !idleTimerEnabled;
    //
    __weak typeof(self) weakSelf = self;
    if (self.willResignActiveObserver == nil) {
        self.willResignActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            BOOL idleTimerDisabled = [weakSelf.idleTimerDisabledSaved boolValue];
            if (weakSelf.idleTimerDisabled != idleTimerDisabled) {
                weakSelf.idleTimerDisabled = idleTimerDisabled;
            }
            weakSelf.idleTimerDisabledSaved = nil;
        }];
    }
    if (self.didEnterBackgroundObserver == nil) {
        self.didEnterBackgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            BOOL idleTimerDisabled = [weakSelf.idleTimerDisabledSaved boolValue];
            if (weakSelf.idleTimerDisabled != idleTimerDisabled) {
                weakSelf.idleTimerDisabled = idleTimerDisabled;
            }
            weakSelf.idleTimerDisabledSaved = nil;
        }];
    }
    if (self.willEnterForegroundObserver == nil) {
        self.willEnterForegroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (weakSelf.idleTimerDisabledSaved == nil) {
                weakSelf.idleTimerDisabledSaved = @(weakSelf.idleTimerDisabled);
            }
            if (weakSelf.idleTimerDisabled == weakSelf.idleTimerEnabled) {
                weakSelf.idleTimerDisabled = !weakSelf.idleTimerEnabled;
            }
        }];
    }
    if (self.didBecomeActiveObserver == nil) {
        self.didBecomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (weakSelf.idleTimerDisabledSaved == nil) {
                weakSelf.idleTimerDisabledSaved = @(weakSelf.idleTimerDisabled);
            }
            if (weakSelf.idleTimerDisabled == weakSelf.idleTimerEnabled) {
                weakSelf.idleTimerDisabled = !weakSelf.idleTimerEnabled;
            }
        }];
    }
}
@end
