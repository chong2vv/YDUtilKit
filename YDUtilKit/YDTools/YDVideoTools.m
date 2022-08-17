//
//  YDVideoTools.m
//  YDUtilKit
//
//  Created by 王远东 on 2022/8/17.
//

#import "YDVideoTools.h"
#import <AVFoundation/AVFoundation.h>

@implementation YDVideoTools

#pragma mark 获取视频文件的缩略图
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
  AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
  NSParameterAssert(asset);
  AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
  assetImageGenerator.appliesPreferredTrackTransform = YES;
  assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
  
  CGImageRef thumbnailImageRef = NULL;
  CFTimeInterval thumbnailImageTime = time;
  NSError *thumbnailImageGenerationError = nil;
  thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
  
  if (!thumbnailImageRef)
    NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
  
  UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
  
  return thumbnailImage;
}

#pragma mark 获取文件大小 单位bytes
+ (CGFloat) getFileSize:(NSString *)path
{
  NSFileManager *fileManager = [[NSFileManager alloc] init];
  float filesize = -1.0;
  if ([fileManager fileExistsAtPath:path]) {
    NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];//获取文件的属性
    unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
    filesize = 1.0*size;
  }
  return filesize;
}

#pragma mark 获取文件长度
+ (CGFloat) getVideoLength:(NSURL *)URL
{
  NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                   forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
  AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
  float second = 0;
  second = urlAsset.duration.value/urlAsset.duration.timescale;
  return second;
}

@end
