//
//  NSString+YDLabelHeigh.m
//  YDUtilKit
//
//  Created by 王远东 on 2022/8/16.
//

#import "NSString+YDLabelHeigh.h"
#import "UILabel+YDAddtion.h"

@implementation NSString (YDLabelHeigh)

- (NSInteger)getNumberOfLinesWithString:(NSString *)string labelWidth:(CGFloat)width font:(CGFloat)font bold:(BOOL)isBold {
    NSInteger number = 1;
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, CGFLOAT_MAX)];
    lb.numberOfLines = 0;
    if (isBold) {
        lb.font = [UIFont boldSystemFontOfSize:font];
    }else {
        lb.font = [UIFont systemFontOfSize:font];
    }
    lb.text = string;
    number = [[lb getSeparatedLinesWithWidth:width] count];
    lb = nil;
    return number;
}

+ (NSInteger)getNumberOfLinesWithString:(NSString *)string labelWidth:(CGFloat)width font:(CGFloat)font bold:(BOOL)isBold {
    NSInteger number = 1;
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, CGFLOAT_MAX)];
    lb.numberOfLines = 0;
    if (isBold) {
        lb.font = [UIFont boldSystemFontOfSize:font];
    }else {
        lb.font = [UIFont systemFontOfSize:font];
    }
    lb.text = string;
    number = [[lb getSeparatedLinesWithWidth:width] count];
    lb = nil;
    return number;
}

@end
