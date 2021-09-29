//
//  UITextField+YDCommon.h
//  app_ios
//
//  Created by 王远东 on 2019/3/17.
//  Copyright © 2019 王远东. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (YDCommon)

/**
 设置所有的文本
 */
- (void)selectAllText;

/**
 设置选择的文本
 
 @param range  选定文本的范围。
 */
- (void)setSelectedRange:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
