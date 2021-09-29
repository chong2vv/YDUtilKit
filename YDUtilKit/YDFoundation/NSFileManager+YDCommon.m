//
//  NSFileManager+YDCommon.m
//  YDUtilKit
//
//  Created by wangyuandong on 2021/9/29.
//

#import "NSFileManager+YDCommon.h"

@implementation NSFileManager (YDCommon)

- (NSUInteger)cleanDiskPath:(NSString *)filePath maxCacheSize:(NSUInteger)maxCacheSize {
    return [self cleanDiskPath:filePath maxCacheAge:-1 maxCacheSize:maxCacheSize];
}

- (NSUInteger)cleanDiskPath:(NSString *)filePath maxCacheAge:(NSTimeInterval)maxCacheAge maxCacheSize:(NSUInteger)maxCacheSize {
    
    NSAssert(maxCacheSize > 0, @"maxCacheSize 必须 > 0");
    NSURL *diskCacheURL = [NSURL fileURLWithPath:filePath isDirectory:YES];
    NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
    
    // This enumerator prefetches useful properties for our cache files.
    NSDirectoryEnumerator *fileEnumerator = [self enumeratorAtURL:diskCacheURL
                                               includingPropertiesForKeys:resourceKeys
                                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                             errorHandler:NULL];
    

    NSDate *expirationDate = maxCacheAge < 0 ? nil : [NSDate dateWithTimeIntervalSinceNow:-maxCacheAge];
    NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
    NSUInteger currentCacheSize = 0;
    NSUInteger cleanFileSize = 0; // 清理文件的大小
    
    // Enumerate all of the files in the cache directory.  This loop has two purposes:
    //
    //  1. Removing files that are older than the expiration date.
    //  2. Storing file attributes for the size-based cleanup pass.
    NSMutableArray *urlsToDelete = [[NSMutableArray alloc] init];
    for (NSURL *fileURL in fileEnumerator) {
        NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
        
        // Skip directories.
        if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
            continue;
        }
        
        // Store a reference to this file and account for its total size.
        NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
        NSUInteger fileSize = [totalAllocatedSize unsignedIntegerValue];
        [cacheFiles setObject:resourceValues forKey:fileURL];
        
        if (expirationDate != nil) {
            
            // Remove files that are older than the expiration date;
            NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
            if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [urlsToDelete addObject:fileURL];
                cleanFileSize += fileSize;
                continue;
            }
            
        }else {
            currentCacheSize += fileSize;
        }
     
    }
    
    for (NSURL *fileURL in urlsToDelete) {
        [self removeItemAtURL:fileURL error:nil];
    }
    
    // If our remaining disk cache exceeds a configured maximum size, perform a second
    // size-based cleanup pass.  We delete the oldest files first.
    if (maxCacheSize > 0 && currentCacheSize > maxCacheSize) {
        // Target half of our maximum cache size for this cleanup pass.
        const NSUInteger desiredCacheSize = maxCacheSize / 2;
        
        // Sort the remaining cache files by their last modification time (oldest first).
        NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                        usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                            return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                        }];
        
        // Delete files until we fall below our desired cache size.
        for (NSURL *fileURL in sortedFiles) {
            if ([self removeItemAtURL:fileURL error:nil]) {
                NSDictionary *resourceValues = cacheFiles[fileURL];
                NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                NSUInteger fileSize = [totalAllocatedSize unsignedIntegerValue];
                currentCacheSize -= fileSize;
                cleanFileSize += fileSize;
                if (currentCacheSize < desiredCacheSize) {
                    break;
                }
            }
        }
    }
    return cleanFileSize;
}


/**
 * 获取目录下的文件数
 */
- (NSInteger)getFileCountByPath:(NSString *)aPath {
    
    if (![self fileExistsAtPath:aPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[self subpathsAtPath:aPath] objectEnumerator];
    return childFilesEnumerator.allObjects.count;
}

#pragma mark - 文件大小计算
//单个文件的大小
- (CGFloat)fileSizeAtPath:(NSString*)filePath {
    
    if ([self fileExistsAtPath:filePath]){
        return [[self attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
//遍历文件夹获得文件夹大小，返回多少b
- (CGFloat)folderSizeAtPath:(NSString*)folderPath {
    
    if (![self fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[self subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize;
}

- (void)enumeratorPath:(NSString *)folderPath block:(void(^)(NSString *path))pathBlock{
   
    if (![self fileExistsAtPath:folderPath]) return;
    NSEnumerator *childFilesEnumerator = [[self subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        if (pathBlock) {
            pathBlock(fileName);
        }
    }
}

#pragma mark - 目录创建
- (void)createDirectoryWithPath:(NSString *)aPath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:aPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:aPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

// 保证该文件目录存在
- (void)createDirectoryAtFilePath:(NSString *)aFilePath {
    
    NSString *path = [aFilePath stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

@end
