//
//  YDDownloader.h
//  YDUtilKit
//
//  Created by 王远东 on 2024/4/3.
//

#import <Foundation/Foundation.h>
#import "YDDownloadTask.h"


NS_ASSUME_NONNULL_BEGIN

@interface YDDownloader : NSObject

/// The default instance of ZXDownloader
+ (instancetype)defaultDownloader;

/// Destination directory of download
@property (nonatomic, copy) NSString *downloadPath;

/// The maximum number of downloads that can execute at the same time, default is 4/6 in iOS/OSX
@property (nonatomic, readonly) NSInteger maxConcurrentDownloadCount;

/// The current number of concurrent downloads
@property (nonatomic, readonly) NSInteger currentConcurrentDownloadCount;

/// Enable to allow untrusted SSL certificates, default YES.
@property (nonatomic, assign) BOOL allowInvalidCertificates;

/// The credential that should be used for authentication.
@property (nonatomic, strong, nullable) NSURLCredential * credential;

/// Got download task for URL
/// @param URL The URL
- (nullable YDDownloadTask *)downloadTaskForURL:(NSURL *)URL;

/// Create or got exist download task with URL
/// @param URL The URL
- (nullable YDDownloadTask *)downloadTaskWithURL:(NSURL *)URL;

/// Suspend the task
/// @param task task The task
- (void)suspendTask:(YDDownloadTask *)task;

/// Suspend all tasks
- (void)suspendAllTasks;

/// Start/Resume the task
/// @param task The task
- (void)resumeTask:(YDDownloadTask *)task;

/// Resume or start all tasks
- (void)resumeAllTasks;

/// Cancel the task
/// @param task The task
- (void)cancelTask:(YDDownloadTask *)task;

/// Cancel all download tasks
- (void)cancelAllTasks;

@end

NS_ASSUME_NONNULL_END
