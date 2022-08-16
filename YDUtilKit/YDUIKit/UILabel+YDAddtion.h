//
//  UILabel+YDAddtion.h
//  YDUtilKit
//
//  Created by 王远东 on 2022/8/16.
//

#import <UIKit/UIKit.h>
#import "UITapGestureRecognizer+YDAddtion.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^TapAction)(void);
@interface UILabel (YDAddtion)

/**
 * @param tailFont 结尾文字字体
 * @param tailText 结尾,如"查看更多"
 * @param tailTextColor 结尾文字颜色
 * @param line 显示几行
 * @param width label多长
 */

- (void)changeLineSpaceForLabelByTruncatingTail:(UIFont *)tailFont withTail:(NSString *)tailText tailTextColor:(UIColor*)tailTextColor showLine:(NSInteger)line labelWidth:(CGFloat)width;

//获取每行文字
- (NSArray *)getSeparatedLinesWithWidth:(CGFloat)width;

@property(nonatomic,copy)NSString *tailText;

@property(nonatomic,copy)TapAction tapAction;

@end

NS_ASSUME_NONNULL_END
