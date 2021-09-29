//
//  UIView+YDQRCode.h
//  YDUtilKit
//
//  Created by wangyuandong on 2021/9/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (YDQRCode)

/**
 [^zh]将文本内容渲染为二维码[$zh]
 [^en]Create QRCode image with str[$]
 */
+ (UIImage *)ty_qrCodeWithString:(NSString *)str width:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
