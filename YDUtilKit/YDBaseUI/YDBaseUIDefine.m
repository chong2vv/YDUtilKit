//
//  YDBaseUIDefine.m
//  YDUtilKit
//
//  Created by wangyuandong on 2021/9/29.
//

#import "YDBaseUIDefine.h"

CGFloat getScreenWidth()
{
    static CGFloat s_scrWidth = 0.f;
    if (s_scrWidth == 0.f){
        s_scrWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    }
    return s_scrWidth;
}

CGFloat getScreenHeight()
{
    static CGFloat s_scrHeight = 0.f;
    if (s_scrHeight == 0.f){
        s_scrHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    }
    return s_scrHeight;
}

CGFloat yd_minimumKeyboardHeight()
{
    if ([UIScreen mainScreen].bounds.size.width >= 414.) {
        return 226.f;
    }
    else {
        return 216.f;
    }
}

CGFloat yd_workImageWidth()
{
    static dispatch_once_t onceToken;
    static CGFloat w = 0.;
    dispatch_once(&onceToken, ^{
        if ([UIScreen mainScreen].bounds.size.width == 320.)
        {
            w = 190.;
        }
        else if ([UIScreen mainScreen].bounds.size.width == 375.)
        {
            w = 220.;
        }
        else if ([UIScreen mainScreen].bounds.size.width == 414.)
        {
            w = 250.;
        }
        else
        {
            w = 250.;
        }
    });
    
    return w;
}

extern CGFloat yd_workGridImageWidth()
{
    static dispatch_once_t onceToken;
    static CGFloat w = 0.;
    dispatch_once(&onceToken, ^{
        w = (SCREEN_W - 20. - 10.)/3.;
    });
    
    return w;
}

CGSize yd_caculateWorkImageSize(CGFloat width, CGSize size)
{
    if (size.width == 0 || size.height == 0) {
        return CGSizeMake(width, width);
    }
    CGFloat h = size.height * (width / size.width);
    
    if (h > width*2.) {
        h = width*2.;
    }
    
    return CGSizeMake(width, h);
}

CGSize yd_scaleImageSize(CGFloat scale, CGSize size)
{
    if (scale <= 0.f) {
        return size;
    }
    return CGSizeMake(size.width * scale, size.height * scale);
}

CGFloat yd_CGFloatPixelRound(CGFloat value)
{
    CGFloat scale = [UIScreen mainScreen].scale;
    return round(value * scale) / scale;
}

BOOL yd_screenHasNotch ()
{
    if(@available(iOS 11.0, *)){
        return [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0;
    }
    return NO;
}

