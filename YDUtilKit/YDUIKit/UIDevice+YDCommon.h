//
//  UIDevice+YDCommon.h
//  app_ios
//
//  Created by 王远东 on 2019/3/17.
//  Copyright © 2019 王远东. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (YDCommon)

/// Device system version (e.g. 8.1)
+ (double)systemVersion;

/// Whether the device is iPad/iPad mini.
@property (nonatomic, readonly) BOOL isPad;

/// Whether the device is a simulator.
@property (nonatomic, readonly) BOOL isSimulator;

/// Wherher the device can make phone calls.
@property (nonatomic, readonly) BOOL canMakePhoneCalls NS_EXTENSION_UNAVAILABLE_IOS("");

/// The device's machine model.  e.g. "iPhone6,1" "iPad4,6"
/// @see http://theiphonewiki.com/wiki/Models
@property (nullable, nonatomic, readonly) NSString *machineModel;

/// The device's machine model name. e.g. "iPhone 5s" "iPad mini 2"
/// @see http://theiphonewiki.com/wiki/Models
@property (nullable, nonatomic, readonly) NSString *machineModelName;
/// The size of the file system in bytes.
@property (nonatomic, readonly) int64_t fileSystemSize;

/// The amount of free space on the file system in bytes.
@property (nonatomic, readonly) int64_t fileSystemFreeSize;

/// The amount of used space on the file system in bytes.
@property (nonatomic, readonly) int64_t fileSystemUsedSize;

/// The CPU bits, the value is 32/64 etc.
@property (nonatomic, readonly) int cpuBits;

/// The CPU type, the value is CPU_TYPE_ARM / CPU_TYPE_ARM64 etc.
@property (nonatomic, readonly) int cpuType;

/// The System's startup time.
@property (nonatomic, readonly) NSDate *systemUptime;

@end

NS_ASSUME_NONNULL_END
