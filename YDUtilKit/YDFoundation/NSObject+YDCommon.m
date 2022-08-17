//
//  NSObject+YDCommon.m
//  YDUtilKit
//
//  Created by 王远东 on 2022/8/17.
//

#import "NSObject+YDCommon.h"

@implementation NSObject (YDCommon)

- (BOOL)isEmpty {
    if (self == nil ||
        self == [NSNull null] ||
        [@"" isEqualToString:[self description]]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isEmpty:(NSObject *)aObj {
    if (aObj == nil ||
        aObj == [NSNull null] ||
        [@"" isEqualToString:[aObj description]]) {
        return YES;
    }
    return NO;
}
@end
