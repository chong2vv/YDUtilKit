//
//  YDDownloader.m
//  YDUtilKit
//
//  Created by 王远东 on 2024/4/3.
//

#import "YDDownloader.h"
#import "YDKeyValueObserver.h"
#import "YDDispatchQueue.h"
#import <UIKit/UIKit.h>
#import "YDTools+YDMacros.h"

@interface YDDownloader () <NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableDictionary *currentTasks;
@property (nonatomic, strong) NSMutableArray *runningTasks;
@property (nonatomic, strong) NSMutableArray *waitingTasks;

@property (nonatomic, weak) id willResignActiveObserver;
@property (nonatomic, weak) id didEnterBackgroundObserver;
@property (nonatomic, weak) id willEnterForegroundObserver;
@property (nonatomic, weak) id didBecomeActiveObserver;

@end

@implementation YDDownloader

+ (instancetype)defaultDownloader {
    static YDDownloader *downloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloader = [[YDDownloader alloc] init];
    });
    return downloader;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentTasks = [[NSMutableDictionary alloc] init];
        _runningTasks = [[NSMutableArray alloc] init];
        _waitingTasks = [[NSMutableArray alloc] init];
        _downloadPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:NSStringFromClass([self class])];
        _allowInvalidCertificates = YES;
        [self addObservers];
    }
    return self;
}

- (void)dealloc {
    [self removeObservers];
}

#pragma mark Session

- (NSURLSession *)session {
    AT_SYNCHRONIZED_SELF_BEGIN
    if (_session == nil) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    AT_SYNCHRONIZED_SELF_END
    return _session;
}

#pragma mark Observers

- (void)addObservers {
    __weak typeof(self) weakSelf = self;
    //
    if (_willResignActiveObserver == nil) {
        _willResignActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [YDDispatchQueue.main asyncAfter:@"YDDownloader.enterBackground/enterForeground" deadline:0.3 execute:^(NSString * _Nonnull event) {
                [weakSelf enterBackground];
            }];
        }];
    }
    if (_didEnterBackgroundObserver == nil) {
        _didEnterBackgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [YDDispatchQueue.main asyncAfter:@"YDDownloader.enterBackground/enterForeground" deadline:0.3 execute:^(NSString * _Nonnull event) {
                [weakSelf enterBackground];
            }];
        }];
    }
    //
    if (_willEnterForegroundObserver == nil) {
        _willEnterForegroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [YDDispatchQueue.main asyncAfter:@"YDDownloader.enterBackground/enterForeground" deadline:0.3 execute:^(NSString * event) {
                [weakSelf enterForeground];
            }];
        }];
    }
    if (_didBecomeActiveObserver == nil) {
        _didBecomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [YDDispatchQueue.main asyncAfter:@"YDDownloader.enterBackground/enterForeground" deadline:0.3 execute:^(NSString * event) {
                [weakSelf enterForeground];
            }];
        }];
    }
}

- (void)removeObservers {
    if (_willResignActiveObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_willResignActiveObserver];
        _willResignActiveObserver = nil;
    }
    if (_didEnterBackgroundObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_didEnterBackgroundObserver];
        _didEnterBackgroundObserver = nil;
    }
    if (_willEnterForegroundObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_willEnterForegroundObserver];
        _willEnterForegroundObserver = nil;
    }
    if (_didBecomeActiveObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_didBecomeActiveObserver];
        _didBecomeActiveObserver = nil;
    }
}

#pragma mark Background && Foreground

- (void)enterBackground {
    AT_SYNCHRONIZED_SELF_BEGIN
    for (YDDownloadTask *task in _currentTasks.allValues) {
        if (task.state == NSURLSessionTaskStateRunning) {
            [_runningTasks addObject:task];
        } else {
            [_waitingTasks addObject:task];
        }
    }
    //
    [self cancelAllTasks];
    _session = nil;
    AT_SYNCHRONIZED_SELF_END
}

- (void)enterForeground {
    AT_SYNCHRONIZED_SELF_BEGIN
    for (YDDownloadTask *obj in _runningTasks) {
        YDDownloadTask *task = [self downloadTaskWithURL:obj.URL];
        id observers = [obj valueForKey:@"observers"];
        [task setValue:observers forKey:@"observers"];
        [task resume];
    }
    [_runningTasks removeAllObjects];
    //
    for (YDDownloadTask *obj in _waitingTasks) {
        YDDownloadTask *task = [self downloadTaskWithURL:obj.URL];
        id observers = [obj valueForKey:@"observers"];
        [task setValue:observers forKey:@"observers"];
    }
    [_waitingTasks removeAllObjects];
    AT_SYNCHRONIZED_SELF_END
}

#pragma mark Concurrency

- (NSInteger)maxConcurrentDownloadCount {
    return self.session.configuration.HTTPMaximumConnectionsPerHost;
}

- (NSInteger)currentConcurrentDownloadCount {
    AT_SYNCHRONIZED_SELF_BEGIN
    NSInteger count = 0;
    for (YDDownloadTask *task in _currentTasks.allValues) {
        if (task.state == NSURLSessionTaskStateRunning) {
            count++;
        }
    }
    return count;
    AT_SYNCHRONIZED_SELF_END
}

#pragma mark Tasks

- (void)addTask:(YDDownloadTask *)task {
    AT_SYNCHRONIZED_SELF_BEGIN
    if (task) {
        [self addTaskObserver:task];
        [_currentTasks setObject:task forKey:task.taskIdentifier];
    }
    AT_SYNCHRONIZED_SELF_END
}

- (void)removeTask:(YDDownloadTask *)task {
    AT_SYNCHRONIZED_SELF_BEGIN
    if (task) {
        [self removeTaskObserver:task];
        [_currentTasks removeObjectForKey:task.taskIdentifier];
    }
    AT_SYNCHRONIZED_SELF_END
}

- (YDDownloadTask *)downloadTaskForURL:(NSURL *)URL {
    AT_SYNCHRONIZED_SELF_BEGIN
    return [_currentTasks objectForKey:URL.taskIdentifier];
    AT_SYNCHRONIZED_SELF_END
}

- (YDDownloadTask *)downloadTaskWithURL:(NSURL *)URL {
    YDDownloadTask *task = [self downloadTaskForURL:URL];
    if (task == nil) {
        task = [[YDDownloadTask alloc] initWithURL:URL path:_downloadPath session:self.session];
        [self addTask:task];
    }
    return task;
}

#pragma mark Resume

- (void)resumeTask:(YDDownloadTask *)task {
    [task resume];
}

- (void)resumeAllTasks {
    AT_SYNCHRONIZED_SELF_BEGIN
    for (YDDownloadTask *task in _currentTasks.allValues) {
        [self resumeTask:task];
    }
    AT_SYNCHRONIZED_SELF_END
}

#pragma mark Suspend

- (void)suspendTask:(YDDownloadTask *)task {
    [task suspend];
}

- (void)suspendAllTasks {
    AT_SYNCHRONIZED_SELF_BEGIN
    for (YDDownloadTask *task in _currentTasks.allValues) {
        [task suspend];
    }
    AT_SYNCHRONIZED_SELF_END
}

#pragma mark Cancel

- (void)cancelTask:(YDDownloadTask *)task {
    [task cancel];
}

- (void)cancelAllTasks {
    AT_SYNCHRONIZED_SELF_BEGIN
    for (YDDownloadTask *task in _currentTasks.allValues) {
        [task cancel];
    }
    AT_SYNCHRONIZED_SELF_END
}

#pragma mark <NSKeyValueObserving>

- (void)addTaskObserver:(YDDownloadTask *)task {
    if (task) {
        [self removeTaskObserver:task];
        YDKeyValueObserver *taskStateObserver = [task valueForKey:@"taskStateObserver"];
        //
        __weak typeof(self) weakSelf = self;
        [taskStateObserver observe:task keyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL changeHandler:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change, void * _Nullable context) {
            NSURLSessionTaskState state = [change[NSKeyValueChangeNewKey] integerValue];
            switch (state) {
                case NSURLSessionTaskStateCanceling:
                case NSURLSessionTaskStateCompleted:
                    [weakSelf removeTask:task];
                    break;
                default:
                    break;
            }
        }];
    }
}

- (void)removeTaskObserver:(YDDownloadTask *)task {
    if (task) {
        YDKeyValueObserver *taskStateObserver = [task valueForKey:@"taskStateObserver"];
        [taskStateObserver invalidate];
    }
}

#pragma mark <NSURLSessionTaskDelegate>

/* The task has received a request specific authentication challenge.
* If this delegate is not implemented, the session specific authentication challenge
* will *NOT* be called and the behavior will be the same as using the default handling
* disposition.
*/
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (self.allowInvalidCertificates) {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            disposition = NSURLSessionAuthChallengeUseCredential;
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    } else {
        if (challenge.previousFailureCount == 0) {
            if (self.credential) {
                credential = self.credential;
                disposition = NSURLSessionAuthChallengeUseCredential;
            } else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

/* Sent as the last message related to a specific task.  Error may be
* nil, which implies that no error occurred and this task is complete.
*/
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    YDDownloadTask *obj = [self downloadTaskForURL:task.URL];
    if (obj) {
        [obj URLSession:session task:task didCompleteWithError:error];
        [self removeTask:obj];
    }
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
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                 didReceiveResponse:(NSURLResponse *)response
                                  completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    YDDownloadTask *task = [self downloadTaskForURL:dataTask.URL];
    if (task) {
        [task URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
    }
    completionHandler(NSURLSessionResponseAllow);
}

/* Sent when data is available for the delegate to consume.  It is
* assumed that the delegate will retain and not copy the data.  As
* the data may be discontiguous, you should use
* [NSData enumerateByteRangesUsingBlock:] to access it.
*/
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                     didReceiveData:(NSData *)data {
    YDDownloadTask *task = [self downloadTaskForURL:dataTask.URL];
    if (task) {
        [task URLSession:session dataTask:dataTask didReceiveData:data];
    }
}
@end
