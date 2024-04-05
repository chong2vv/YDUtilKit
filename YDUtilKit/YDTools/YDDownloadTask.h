//
//  YDDownloadTask.h
//  YDUtilKit
//
//  Created by 王远东 on 2024/4/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YDDownloadTask : NSObject<NSURLSessionDataDelegate>

/// The unique identifier for task
@property (nonatomic, readonly) NSURL *URL;

/// The unique identifier for task
@property (nonatomic, readonly) NSString *taskIdentifier;

/// The current state of the task—active, suspended, in the process of being canceled, or completed.
@property (nonatomic, readonly) NSURLSessionTaskState state;

/// Location of the downloaded file
@property (nonatomic, readonly) NSString *filePath;

/// Total bytes written
@property (nonatomic, readonly) int64_t totalBytesWritten;

/// Total bytes expected to write
@property (nonatomic, readonly) int64_t totalBytesExpectedToWrite;

/// Init
/// @param URL The download URL
/// @param path The local path of download
/// @param session The URL session
- (instancetype)initWithURL:(NSURL *)URL path:(NSString *)path session:(NSURLSession *)session;

/// Add observer
/// @param observer The observer
/// @param state A block object to be executed when the download state changed.
/// @param progress  A block object to be executed when the download progress changed.
- (void)addObserver:(id)observer
              state:(void(^_Nullable)(NSURLSessionTaskState state, NSString *_Nullable filePath, NSError *_Nullable error))state
           progress:(void(^_Nullable)(int64_t receivedSize, int64_t expectedSize, float progress))progress;

/// Remove observer
/// @param observer observer The observer
- (void)removeObserver:(id)observer;

/// Cancel the task
- (void)cancel;

/// Suspend the task
- (void)suspend;

/// Resume the task. If the destination file exists, will be issued by state observer a NSFileWriteFileExistsError error
- (void)resume;

@end

@interface NSURL (YDDownloadTask)

/// An unique identifier for URL
- (nullable NSString *)taskIdentifier;

@end

@interface NSURLSessionTask (YDDownloadTask)

/// The URL of task
- (nullable NSURL *)URL;
@end

NS_ASSUME_NONNULL_END
