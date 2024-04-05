//
//  YDDownloadTask.m
//  YDUtilKit
//
//  Created by 王远东 on 2024/4/3.
//

#import "YDDownloadTask.h"
#import "YDDownloader.h"
#import "YDKeyValueObserver.h"
#import <UIKit/UIKit.h>
#import "NSString+YDCommon.h"


/// YDDownloadObserver
@interface YDDownloadObserver : NSObject

/// The observer
@property (nonatomic, weak) id observer;

/// The progress block
@property (nonatomic, copy) void(^progress)(int64_t receivedSize, int64_t expectedSize, float progress);

/// The state block
@property (nonatomic, copy) void(^state)(NSURLSessionTaskState state, NSString *filePath, NSError *error);

@end

@implementation YDDownloadObserver

@end

@interface YDDownloadTask ()

@property (nonatomic, strong) NSURLSessionTask *task;

@property (nonatomic, strong) NSMutableArray *observers;

@property (nonatomic, strong) NSString *temporaryFilePath;
@property (nonatomic, strong) NSString *destinationFilePath;

@property (nonatomic, strong) NSOutputStream *outputStream;

@property (nonatomic, assign) int64_t totalBytesWritten;
@property (nonatomic, assign) int64_t totalBytesExpectedToWrite;

@property (nonatomic, assign) NSURLSessionTaskState state;

@property (nonatomic, strong) YDKeyValueObserver *taskStateObserver;
@property (nonatomic, weak) NSURLSession *session;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@end

@implementation YDDownloadTask

- (instancetype)initWithURL:(NSURL *)URL path:(NSString *)path session:(NSURLSession *)session {
    self = [super init];
    if (self) {
        //
        _session = session;
        _observers = [[NSMutableArray alloc] init];
        _taskStateObserver = [[YDKeyValueObserver alloc] init];
        _state = NSURLSessionTaskStateSuspended;
        _semaphore = dispatch_semaphore_create(1);
        //
        BOOL isDirectory = NO;
        if (path == nil) {
            path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        }
        BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
        if (!isExists || !isDirectory) {
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        //
        if (URL) {
            _URL = [URL copy];
            _taskIdentifier = _URL.taskIdentifier;
            _temporaryFilePath = [path stringByAppendingPathComponent:_taskIdentifier];
            _destinationFilePath = [path stringByAppendingPathComponent:[_URL lastPathComponent]];
            _totalBytesWritten = [self fileSizeAtPath:_temporaryFilePath];
            _totalBytesExpectedToWrite = 0;
            //
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_URL];
            if (_totalBytesWritten > 0) {
                // Range
                // bytes=x-y ==  x byte ~ y byte
                // bytes=x-  ==  x byte ~ end
                // bytes=-y  ==  head ~ y byte
                [request setValue:[NSString stringWithFormat:@"bytes=%lld-", _totalBytesWritten] forHTTPHeaderField:@"Range"];
            }
            //
            _task = [_session dataTaskWithRequest:[request copy]];
        }
    }
    return self;
}

#pragma mark Observer

- (void)addObserver:(id)observer
              state:(void(^)(NSURLSessionTaskState state, NSString *filePath, NSError *error))state
           progress:(void(^)(int64_t receivedSize, int64_t expectedSize, float progress))progress {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    YDDownloadObserver *taskObserver = [[YDDownloadObserver alloc] init];
    taskObserver.observer = observer;
    taskObserver.state = state;
    taskObserver.progress = progress;
    [_observers addObject:taskObserver];
    dispatch_semaphore_signal(_semaphore);
}

- (void)removeObserver:(id)observer {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (YDDownloadObserver *obj in _observers) {
        if (obj.observer == observer) {
            [array addObject:obj];
        }
    }
    [self.observers removeObjectsInArray:array];
    dispatch_semaphore_signal(_semaphore);
}

#pragma mark Files

- (NSString *)filePath {
    if (_state == NSURLSessionTaskStateCompleted) {
        return _destinationFilePath;
    }
    return _temporaryFilePath;
}

- (uint64_t)fileSizeAtPath:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        if (attributes) {
            return [attributes[NSFileSize] longLongValue];
        }
    }
    return 0;
}

#pragma mark State

- (void)cancel {
    if (_state == NSURLSessionTaskStateRunning ||
        _state == NSURLSessionTaskStateSuspended) {
        [_task cancel];
    }
}

- (void)suspend {
    if (_state == NSURLSessionTaskStateRunning) {
        [_task suspend];
        [self setState:NSURLSessionTaskStateSuspended withError:nil];
    }
}

- (void)resume {
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:_destinationFilePath isDirectory:&isDir] && !isDir) {
        id userInfo = @{NSLocalizedFailureReasonErrorKey:@"Could not perform an operation because the destination file already exists.", @"NSDestinationFilePath":_destinationFilePath};
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteFileExistsError userInfo:userInfo];
        [self setState:NSURLSessionTaskStateCompleted withError:error];
    } else if (_state == NSURLSessionTaskStateSuspended) {
        [_task resume];
        [self setState:NSURLSessionTaskStateRunning withError:nil];
    } else if (_state == NSURLSessionTaskStateCompleted) {
        [self setState:NSURLSessionTaskStateCompleted withError:nil];
    }
}

- (void)setState:(NSURLSessionTaskState)state {
    [self willChangeValueForKey:@"state"];
    _state = state;
    [self didChangeValueForKey:@"state"];
}

- (void)setState:(NSURLSessionTaskState)state withError:(NSError *)error {
    if (state == NSURLSessionTaskStateCompleted) {
        if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
            state = NSURLSessionTaskStateCanceling;
            error = nil;
        }
    }
    //
    self.state = state;
    //
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSString *path = self.filePath;
    for (YDDownloadObserver *observer in self.observers) {
        if (observer.observer && observer.state) {
            dispatch_async(dispatch_get_main_queue(), ^{
                observer.state(state, path, error);
            });
        }
    }
    dispatch_semaphore_signal(_semaphore);
}

#pragma mark Progress

- (void)setTotalBytesWritten:(int64_t)totalBytesWritten {
    if (_totalBytesWritten != totalBytesWritten) {
        [self setTotalBytesWritten:totalBytesWritten
         totalBytesExpectedToWrite:_totalBytesExpectedToWrite];
    }
}

- (void)setTotalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (_totalBytesExpectedToWrite != totalBytesExpectedToWrite) {
        [self setTotalBytesWritten:_totalBytesWritten
         totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

- (void)setTotalBytesWritten:(int64_t)totalBytesWritten
   totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    _totalBytesWritten = totalBytesWritten;
    _totalBytesExpectedToWrite = totalBytesExpectedToWrite;
    //
    float progress = 0.f;
    if (_totalBytesExpectedToWrite > 0) {
        progress = (float)_totalBytesWritten / _totalBytesExpectedToWrite;
        if (progress > 1.0) {
            progress = 1.0;
        }
    }
    //
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (YDDownloadObserver *observer in weakSelf.observers) {
            if (observer.observer && observer.progress) {
                observer.progress(totalBytesWritten, totalBytesExpectedToWrite, progress);
            }
        }
    });
}

#pragma mark Output Stream

- (void)openOutputStreamWithAppend:(BOOL)append {
    if (_outputStream == nil) {
        _outputStream = [NSOutputStream outputStreamToFileAtPath:_temporaryFilePath append:append];
        [_outputStream open];
    }
}

- (void)closeOutputStream {
    if (_outputStream) {
        if (_outputStream.streamStatus > NSStreamStatusNotOpen &&
            _outputStream.streamStatus < NSStreamStatusClosed) {
            [_outputStream close];
        }
        _outputStream = nil;
    }
}

#pragma mark <NSURLSessionTaskDelegate>

/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    [self closeOutputStream];
    if (error == nil && task.state == NSURLSessionTaskStateCompleted) {
        [[NSFileManager defaultManager] removeItemAtPath:_destinationFilePath error:nil];
        [[NSFileManager defaultManager] moveItemAtPath:_temporaryFilePath
                                                toPath:_destinationFilePath
                                                 error:&error];
    } else {
        NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
        userInfo[NSURLErrorKey] = _task.URL.absoluteString;
        error = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
    }
    [self setState:task.state withError:error];
}

#pragma mark <NSURLSessionDataDelegate>

/* The task has received a response and no further messages will be
 * received until the completion block is called. The disposition
 * allows you to cancel a request or to turn a data task into a
 * download task. This delegate message is optional - if you do not
 * implement it, you can get the response as a property of the task.
 *
 * This method will not be called for background upload tasks (which cannot be converted to download tasks).
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
        switch (http.statusCode) {
            case 200: // OK
            {
                _totalBytesWritten = 0;
                self.totalBytesExpectedToWrite = http.expectedContentLength;
                [self openOutputStreamWithAppend:NO];
                break;
            }
            case 206: // Partial Content
            {
                self.totalBytesExpectedToWrite = _totalBytesWritten + http.expectedContentLength;
                [self openOutputStreamWithAppend:YES];
                break;
            }
            case 416: // Requested Range Not Satisfiable
            {
                [[NSFileManager defaultManager] removeItemAtPath:_temporaryFilePath error:nil];
                id userInfo = @{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"%ld %@", (long)http.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:http.statusCode]], NSURLErrorKey:_task.URL.absoluteString};
                NSError *error = [NSError errorWithDomain:@"HTTPStatusCode" code:http.statusCode userInfo:userInfo];
                [self setState:NSURLSessionTaskStateCompleted withError:error];
                break;
            }
            default:
            {
                id userInfo = @{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"%ld %@", (long)http.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:http.statusCode]], NSURLErrorKey:_task.URL.absoluteString};
                NSError *error = [NSError errorWithDomain:@"HTTPStatusCode" code:http.statusCode userInfo:userInfo];
                [self setState:NSURLSessionTaskStateCompleted withError:error];
                return;
            }
        }
    }
}

/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use
 * [NSData enumerateByteRangesUsingBlock:] to access it.
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    if (data) {
        [_outputStream write:data.bytes maxLength:data.length];
        self.totalBytesWritten += data.length;
    }
}

@end

@implementation NSURL (YDDownloadTask)

- (nullable NSString *)taskIdentifier {
    NSMutableString *url = [[NSMutableString alloc] init];
    if (self.scheme) {
        [url appendFormat:@"%@://", self.scheme];
    }
    if (self.host) {
        [url appendString:self.host];
    }
    if (self.port) {
        [url appendFormat:@":%d", self.port.intValue];
    }
    if (self.path) {
        [url appendFormat:@"%@", self.path];
    }
    if (url.length) {
        return [[url sha1String] lowercaseString];
    }
    return nil;
}

@end

@implementation NSURLSessionTask (YDDownloadTask)

- (nullable NSURL *)URL {
    return self.originalRequest.URL ?: self.currentRequest.URL;
}

@end
