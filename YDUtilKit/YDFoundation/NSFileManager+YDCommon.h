//
//  NSFileManager+YDCommon.h
//  YDUtilKit
//
//  Created by wangyuandong on 2021/9/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (YDCommon)

/**
 *  从最早的文件开始删除直到 缓存大小不到最大限制
 *  @param filePath         要清理的文件目录
 *  @param maxCacheSize     文件缓存最大限制
 *  return                  返回清理文件的大小
 */

- (NSUInteger)cleanDiskPath:(NSString *)filePath maxCacheSize:(NSUInteger)maxCacheSize;

/**
 *  文件清理  先清理过期的文件，剩于文件如果大于文件最大限制，就从最早的开始删除
 *  @param filePath         要清理的文件目录
 *  @param maxCacheAge      文件存留时间，该时间内的放过
 *  @param maxCacheSize     文件缓存最大限制
 *  return                  返回清理文件的大小
 */

- (NSUInteger)cleanDiskPath:(NSString *)filePath maxCacheAge:(NSTimeInterval)maxCacheAge maxCacheSize:(NSUInteger)maxCacheSize;

/**
 * 获取目录下的文件数
 */
- (NSInteger)getFileCountByPath:(NSString *)aPath;

#pragma mark - 文件大小计算
/*
 * 单个文件的大小
 */
- (CGFloat)fileSizeAtPath:(NSString*)filePath;

/*
 *遍历文件夹获得文件夹大小，返回多少b
 */
- (CGFloat)folderSizeAtPath:(NSString*)folderPath;

#pragma mark - 目录创建
// 保证目录存在
- (void)createDirectoryWithPath:(NSString *)aPath;
// 保证该文件目录存在
- (void)createDirectoryAtFilePath:(NSString *)aFilePath;

@end

NS_ASSUME_NONNULL_END
