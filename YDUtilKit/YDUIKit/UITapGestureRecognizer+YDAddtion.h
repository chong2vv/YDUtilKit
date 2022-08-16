//
//  UITapGestureRecognizer+YDAddtion.h
//  YDUtilKit
//
//  Created by 王远东 on 2022/8/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITapGestureRecognizer (YDAddtion)

- (BOOL)didTapAttributedTextInLabel:(UILabel *)label inRange:(NSRange)targetRange;

@end

NS_ASSUME_NONNULL_END
