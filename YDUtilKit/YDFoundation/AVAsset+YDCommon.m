//
//  AVAsset+YDCommon.m
//  YDUtilKit
//
//  Created by 王远东 on 2023/10/30.
//

#import "AVAsset+YDCommon.h"

@implementation AVAsset (YDCommon)

- (UIImage *)copyImageAtTime:(NSTimeInterval)time {
    return [self copyImageAtTime:time tolerance:kCMTimePositiveInfinity];
}

- (UIImage *)copyImageAtTime:(NSTimeInterval)time tolerance:(CMTime)tolerance {
    UIImage *image = nil;
    //
    AVAssetTrack *track = [[self tracksWithMediaType: AVMediaTypeVideo] firstObject];
    if (track) {
        CMTime atTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
        CMTime actualTime = kCMTimeZero;
        NSError *error = nil;
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:self];
        generator.appliesPreferredTrackTransform = YES;
        generator.requestedTimeToleranceBefore = tolerance;
        generator.requestedTimeToleranceAfter = tolerance;
        CGImageRef imageRef = [generator copyCGImageAtTime:atTime actualTime:&actualTime error:&error];
        if (imageRef) {
            image = [[UIImage alloc] initWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
        if (image) {
            NSLog(@"copyImageAtTime:%.3f torlerance:%.3f actualTime:%.3f", time, CMTimeGetSeconds(tolerance), CMTimeGetSeconds(actualTime));
        }
        if (error) {
            NSLog(@"copyImageAtTime:%.3f torlerance:%.3f error:%@", time, CMTimeGetSeconds(tolerance), error);
        }
    }
    //
    return image;
}

- (void)copyImageAtTime:(NSTimeInterval)time tolerance:(CMTime)tolerance completion:(void (^ _Nullable)(UIImage * _Nullable image, NSError * _Nullable error))completion {
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:self];
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = tolerance;
    generator.requestedTimeToleranceAfter = tolerance;
    NSValue *value = [NSValue valueWithCMTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
    [generator generateCGImagesAsynchronouslyForTimes:@[value] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        UIImage *image = nil;
        if (imageRef) {
            image = [[UIImage alloc] initWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
        if (image) {
            NSLog(@"copyImageAtTime:%.3f torlerance:%.3f actualTime:%.3f", time, CMTimeGetSeconds(tolerance), CMTimeGetSeconds(actualTime));
        }
        if (error) {
            NSLog(@"copyImageAtTime:%.3f torlerance:%.3f error:%@", time, CMTimeGetSeconds(tolerance), error);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(image, error);
            }
        });
    }];
}


@end
