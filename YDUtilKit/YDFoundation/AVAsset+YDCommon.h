//
//  AVAsset+YDCommon.h
//  YDUtilKit
//
//  Created by 王远东 on 2023/10/30.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAsset (YDCommon)

/// Return an image for video at or near the specified time.
/// @param time The requested time
- (nullable UIImage *)copyImageAtTime:(NSTimeInterval)time;

/// Return an image for video at or near the specified time.
/// @param time The requested time
/// @param tolerance The temporal tolerance time.
/// Pass kCMTimeZero to request sample accurate seeking (this may incur additional decoding delay).
- (nullable UIImage *)copyImageAtTime:(NSTimeInterval)time tolerance:(CMTime)tolerance;

/// Creates a series of image objects for an asset at or near specified times.
/// @param time The requested time
/// @param tolerance The temporal tolerance time.
/// @param completion The completion block
- (void)copyImageAtTime:(NSTimeInterval)time tolerance:(CMTime)tolerance completion:(void (^ _Nullable)(UIImage * _Nullable image, NSError * _Nullable error))completion;


@end

NS_ASSUME_NONNULL_END
