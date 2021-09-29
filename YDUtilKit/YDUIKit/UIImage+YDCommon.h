//
//  UIImage+YDCommon.h
//  app_ios
//
//  Created by 王远东 on 2019/3/17.
//  Copyright © 2019 王远东. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GradientType) {
    GradientTypeTopToBottom = 0,//从上到下
    GradientTypeLeftToRight = 1,//从左到右
    GradientTypeUpleftToLowright = 2,//左上到右下
    GradientTypeUprightToLowleft = 3,//右上到左下
};


NS_ASSUME_NONNULL_BEGIN

@interface UIImage (YDCommon)

/**
 生成并返回纯颜色的image
 
 @param color  颜色
 */
+ (nullable UIImage *)imageWithColor:(UIColor *)color;

/**
 生成并返回固定尺寸的纯颜色image
 
 @param color  颜色
 @param size   尺寸
 */
+ (nullable UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 创建GIF对应比例的image
 
 @param data     GIF数据
 
 @param scale    指定比例
 
 @return GIF动画后的Image
 */
+ (nullable UIImage *)imageWithSmallGIFData:(NSData *)data scale:(CGFloat)scale;

/**
 判断是否是GIF
 
 @param data image数据
 
 */
+ (BOOL)isAnimatedGIFData:(NSData *)data;

/**
 判断是否是GIF
 
 @param path GIF图片路径
 
 */
+ (BOOL)isAnimatedGIFFile:(NSString *)path;

/**
 创建PDF的image
 
 @param dataOrPath PDF的data或者路径
 
 */
+ (nullable UIImage *)imageWithPDF:(id)dataOrPath;

/**
 创建PDF的image并指定大小
 
 @param dataOrPath  PDF的data或者路径
 
 @param size     生成PDF的大小
 
 */
+ (nullable UIImage *)imageWithPDF:(id)dataOrPath size:(CGSize)size;

/**
 图片左转90°. ⤺
 宽高兑换
 */
- (nullable UIImage *)imageByRotateLeft90;

/**
 图片右转90°. ⤼
 宽高兑换
 */
- (nullable UIImage *)imageByRotateRight90;

/**
 图片旋转 180° . ↻
 */
- (nullable UIImage *)imageByRotate180;

/**
 获取图片大小
 */
- (NSUInteger)imageCost;


/**
 调整图片分辨率/尺寸（等比例缩放

 @param size 最大尺寸
 @return 裁剪后的图片
 */
- (UIImage *)cropImageToMaxSize:(CGSize)size;


/**
 压缩图片到指定文件大小范围内

 @param maxSize 最大文件大小
 @return 压缩后图片data
 */
- (NSData *)halfFuntionForMaxFileSize:(NSInteger)maxSize;

/**
 生成渐变色image

 @param colors 多个@[color]
 @param gradientType 渐变方向
 @param imgSize 图片大小
 @return UIImage
 */
+ (UIImage *)gradientColorImageFromColors:(NSArray*)colors gradientType:(GradientType)gradientType imgSize:(CGSize)imgSize;

/**
 根据CIImage生成指定大小的UIImage

 @param image CIImage
 @param size  图片宽度
 @return UIImage
 */
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size;

@end

NS_ASSUME_NONNULL_END
