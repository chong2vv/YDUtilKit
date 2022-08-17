//
//  YDNumberSender.m
//  YDUtilKit
//
//  Created by 王远东 on 2022/8/17.
//

#import "YDNumberSender.h"
#import <YDUtilKit/YDFoundationCategory.h>

@interface YDNumberSender ()

@property (class, nonatomic, assign) NSInteger upNumber;

@end

static NSInteger _upNumber = 0;

@implementation YDNumberSender

+ (NSString *)getSenderNumber {
    
    NSString *numberStr = @"";
    numberStr = [numberStr stringByAppendingFormat:@"%@", [NSDate getNowTimeTimestamp]];
    numberStr = [numberStr stringByAppendingFormat:@"%ld", (long)YDNumberSender.upNumber];
    int randomNumber = (arc4random() % 10);
    numberStr = [numberStr stringByAppendingFormat:@"%ld", (long)randomNumber];
    YDNumberSender.upNumber ++;
    if (YDNumberSender.upNumber == 9) {
        YDNumberSender.upNumber = 0;
    }
    
    return numberStr;
}

+ (NSInteger)upNumber {
    return _upNumber;
}

+ (void)setUpNumber:(NSInteger)upNumber {
    if (upNumber != _upNumber) {
        _upNumber = upNumber;
    }
}

@end
