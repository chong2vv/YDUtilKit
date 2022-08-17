//
//  YDNetworkTools.m
//  YDUtilKit
//
//  Created by 王远东 on 2022/8/17.
//

#import "YDNetworkTools.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <AVFoundation/AVFoundation.h>
#include <sys/param.h>
#include <sys/mount.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <CoreTelephony/CTCellularData.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

static CTCellularData *yd_cellularData = nil;
@implementation YDNetworkTools
+ (void)load
{
    //取网络状态,必须在startMonitoring后,否则状态不更新
    [AFNetworkReachabilityManager.sharedManager startMonitoring];
    yd_cellularData = CTCellularData.new;
    yd_cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state) {
        NSLog(@"CTCellularDataRestrictedState:%ld",state);
    };
}

+ (BOOL)isCellularDataOpened
{
    switch (yd_cellularData.restrictedState) {
        case kCTCellularDataNotRestricted://未限制
            return YES;
        case kCTCellularDataRestrictedStateUnknown://未知
        case kCTCellularDataRestricted://限制
            return NO;
    };
}

#pragma mark 当前网络相关
+ (BOOL)networkReachable
{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

+ (BOOL)networkReachableViaWWAN {
    return [AFNetworkReachabilityManager sharedManager].isReachableViaWWAN;
}

+ (BOOL)networkReachableViaWiFi {
    return [AFNetworkReachabilityManager sharedManager].isReachableViaWiFi;
}

+ (void)startMonitoringChangeBlock:(void (^)(AFNetworkReachabilityStatus status))block{
    //创建网络监听管理者对象
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    /*
     typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
     AFNetworkReachabilityStatusUnknown          = -1,//未识别的网络
     AFNetworkReachabilityStatusNotReachable     = 0,//不可达的网络(未连接)
     AFNetworkReachabilityStatusReachableViaWWAN = 1,//2G,3G,4G...
     AFNetworkReachabilityStatusReachableViaWiFi = 2,//wifi网络
     };
     */
    //设置监听
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (block) {
            block(status);
        }
#if DEBUG
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未识别的网络");
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"不可达的网络(未连接)");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"2G,3G,4G...的网络");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"wifi的网络");
                break;
            default:
                break;
        }
#endif
    }];
    //开始监听
    [manager startMonitoring];
}

+ (void)stopMonitoring{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

#pragma mark 获取设备当前网络相关信息
//获取ssid名称
+ (NSString *)getSSIDName
{
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
//    DebugLog(@"ifs is %@",ifs);
    id infossid = nil;
    for (NSString *ifnam in ifs) {
        infossid = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
//        DebugLog(@"ssid is %@",infossid);
        if (infossid && [infossid count]) {
            break;
        }
    }
    NSDictionary *dic = (NSDictionary *)infossid;
    NSString *ssid = [dic objectForKey:@"SSID"];
//    NSString *bssid = [dic objectForKey:@"BSSID"];
//    DebugLog(@"ssid:%@ \nbssid:%@ ",ssid,bssid);
    return ssid ;
}

+ (NSString *)getMacAddress
{
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
//    DebugLog(@"ifs is %@",ifs);
    id infossid = nil;
    for (NSString *ifnam in ifs) {
        infossid = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
//        DebugLog(@"ssid is %@",infossid);
        if (infossid && [infossid count]) {
            break;
        }
    }
    NSDictionary *dic = (NSDictionary *)infossid;
//    NSString *ssid = [dic objectForKey:@"SSID"];
    NSString *bssid = [dic objectForKey:@"BSSID"];
//    DebugLog(@"ssid:%@ \nbssid:%@ ",ssid,bssid);
    return bssid ;
}

+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

+ (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            //输出结果
            NSLog(@"%@",result);
            return YES;
        }
    }
    return NO;
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

+ (NSString *)getWifiName {
    NSString *ssid = @"Not Found";
//     NSString *macIp = @"Not Found";
     CFArrayRef myArray = CNCopySupportedInterfaces();
     if (myArray != nil) {
         CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
         if (myDict != nil) {
                NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
                ssid = [dict valueForKey:@"SSID"];
//                macIp = [dict valueForKey:@"BSSID"];
            }
     }
    return ssid;
}

@end
