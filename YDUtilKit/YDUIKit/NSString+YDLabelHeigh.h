//
//  NSString+YDLabelHeigh.h
//  YDUtilKit
//
//  Created by 王远东 on 2022/8/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (YDLabelHeigh)

- (NSInteger)getNumberOfLinesWithString:(NSString *)string labelWidth:(CGFloat)width font:(CGFloat)font bold:(BOOL) isBold;

+ (NSInteger)getNumberOfLinesWithString:(NSString *)string labelWidth:(CGFloat)width font:(CGFloat)font bold:(BOOL) isBold;

@end

NS_ASSUME_NONNULL_END
