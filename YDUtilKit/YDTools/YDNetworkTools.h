//
//  YDNetworkTools.h
//  YDUtilKit
//
//  Created by 王远东 on 2022/8/17.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface YDNetworkTools : NSObject
#pragma mark - 网络相关

//当前是否有网络
+ (BOOL)networkReachable;
//当前是否可以通过wwan访问
+ (BOOL)networkReachableViaWWAN;
//当前是否可以通过wifi访问
+ (BOOL)networkReachableViaWiFi;
//开启网络状态监控
+ (void)startMonitoringChangeBlock:(void (^)(AFNetworkReachabilityStatus status))block;
//停止监控
+ (void)stopMonitoring;
//是否开放蜂窝数据
+ (BOOL)isCellularDataOpened;
+ (NSString *)getSSIDName;
+ (NSString *)getMacAddress;
+ (NSString *)getIPAddress:(BOOL)preferIPv4;
+ (NSString *)getWifiName;

@end

NS_ASSUME_NONNULL_END
