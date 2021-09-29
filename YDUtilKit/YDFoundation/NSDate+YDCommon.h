//
//  NSDate+YDCommon.h
//  app_ios
//
//  Created by 王远东 on 2019/3/17.
//  Copyright © 2019 王远东. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (YDCommon)

@property (nonatomic, readonly) NSInteger year; ///< Year component
@property (nonatomic, readonly) NSInteger month; ///< Month component (1~12)
@property (nonatomic, readonly) NSInteger day; ///< Day component (1~31)
@property (nonatomic, readonly) NSInteger hour; ///< Hour component (0~23)
@property (nonatomic, readonly) NSInteger minute; ///< Minute component (0~59)
@property (nonatomic, readonly) NSInteger second; ///< Second component (0~59)
@property (nonatomic, readonly) NSInteger nanosecond; ///< Nanosecond component
@property (nonatomic, readonly) NSInteger weekday; ///< Weekday component (1~7,

/**
 * 转换时间戳（具体到日）
 */
+ (NSString *)UTCchangeDate:(NSString *)utc;

/**
 * 转换时间戳（具体到分）
 */
+ (NSString *)UTCchangeDateDetail:(NSInteger )utc;

/**
 * 获取当前时间戳
 */
+ (NSString *)getNowTimeTimestamp;

/**
 当前日期向后移动n年后的日期
 
 @param years  移动年份

 */
- (nullable NSDate *)dateByAddingYears:(NSInteger)years;

/**
 当前日期向后移动n个月后的日期
 
 @param months  移动月份
 
 */
- (nullable NSDate *)dateByAddingMonths:(NSInteger)months;

/**
 当前日期向后移动n周后的日期
 
 @param weeks  移动周数

 */
- (nullable NSDate *)dateByAddingWeeks:(NSInteger)weeks;

/**
 当前日期向后移动n天后的日期
 
 @param days  移动天数
 
 */
- (nullable NSDate *)dateByAddingDays:(NSInteger)days;

/**
 当前日期向后移动n小时后的日期
 
 @param hours  移动小时
 
 */
- (nullable NSDate *)dateByAddingHours:(NSInteger)hours;

/**
 当前日期向后移动n分钟后的日期
 
 @param minutes  移动分钟
 
 */
- (nullable NSDate *)dateByAddingMinutes:(NSInteger)minutes;

/**
 当前日期向后移动n秒后的日期
 
 @param seconds  移动秒数
 
 */
- (nullable NSDate *)dateByAddingSeconds:(NSInteger)seconds;

/**
 日期格式转化
 
 */
- (nullable NSString *)stringWithFormat:(NSString *)format;

/**
 该月多少天
 */
-(NSInteger)numDaysInMonth;

-(NSInteger)firstWeekDayInMonth;

/**
 本月第几周
 */
-(NSInteger)currentMonthWeek;

@end

NS_ASSUME_NONNULL_END
