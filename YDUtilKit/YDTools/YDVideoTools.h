//
//  YDVideoTools.h
//  YDUtilKit
//
//  Created by 王远东 on 2022/8/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YDVideoTools : NSObject
//视频相关
//获取封面图
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;
//获取视频大小
+ (CGFloat) getFileSize:(NSString *)path;
//获取视频大小
+ (CGFloat) getVideoLength:(NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
