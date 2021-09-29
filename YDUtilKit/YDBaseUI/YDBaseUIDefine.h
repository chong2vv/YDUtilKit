//
//  YDBaseUIDefine.h
//  YDUtilKit
//
//  Created by wangyuandong on 2021/9/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H [UIScreen mainScreen].bounds.size.height
#define kScreenScale [UIScreen mainScreen].scale

#define kScaleFactor ydScaleFactor()
// 一般适配
#define kydIphoneScaleFactor ydIphoneScaleFactor()

#define YDRealValue(value) ((value)/667.0f*[UIScreen mainScreen].bounds.size.height)


#define IOS8            ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0)
#define IOS9            ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 9.0)
#define IOS11OrLater    @available(iOS 11.0, *)
#define IOS12OrLater    @available(iOS 12.0, *)


#define UI_IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define UI_IS_IPHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define UI_IS_IPHONE4 (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height < 568.0)
#define UI_IS_IPHONE5 (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define UI_IS_IPHONE6 (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define UI_IS_IPHONE6PLUS (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0 || [[UIScreen mainScreen] bounds].size.width == 736.0)
#define UI_IS_IPHONE_X yd_screenHasNotch()



#pragma mark - UIColor宏定义
#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

#define UIColorFromRGB(rgbValue) UIColorFromRGBA(rgbValue, 1.0)
#define UIColorFromHexString(hex) [UIColor colorWithHexString:hex]
#define UIColorFromRGBValues(r,g,b) [UIColor yd_colorWithRed:r green:g blue:b alpha:1.0]


#define YDSafeKeyPath(aClass, keypath) \
        ((void)(NO && ((void)({aClass *instance; instance.keypath;}), NO)), @ # keypath )


#if DEBUG

#else
#define NSLog(...)
#endif

#ifdef __cplusplus
extern "C" {
#endif
    CGFloat getScreenWidth();
    
    CGFloat getScreenHeight();
    
//    // 获取状态栏竖边高度
//    CGFloat getStatusBarHeight();
//
//    void setStatusBarHeight(CGFloat newH);
#ifdef __cplusplus
}
#endif

extern BOOL yd_screenHasNotch(void);

extern CGFloat yd_minimumKeyboardHeight(void);
extern CGFloat yd_workImageWidth(void);
extern CGFloat yd_workGridImageWidth(void);

extern CGSize yd_caculateWorkImageSize(CGFloat width, CGSize size);
extern CGSize yd_svoidcaleImageSize(CGFloat scale, CGSize size);

//计算像素近似值
extern CGFloat yd_CGFloatPixelRound(CGFloat value);

// iPad -> iPhone UI适配
inline static CGFloat ydScaleFactor()
{
    // Frame缩放系数，原宽/高 * kFrameScaleFactor
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return 1.0;
    } else {
        return 0.8;
    }
}

// iPhone - >iPad  UI适配
inline static CGFloat ydIphoneScaleFactor()
{
    // Frame缩放系数，原宽/高 * kFrameScaleFactor
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return 1.25;
    } else {
        return 1.0;
    }
}

static inline void uiswizzling_exchangeMethod(Class clazz ,SEL originalSelector, SEL swizzledSelector){
    Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector);
    
    BOOL success = class_addMethod(clazz, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(clazz, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
