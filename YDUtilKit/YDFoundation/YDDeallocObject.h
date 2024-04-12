//
//  YDDeallocObject.h
//  YDUtilKit
//
//  Created by 王远东 on 2024/4/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^YDDeallocBlock)(void);

@interface YDDeallocObject : NSObject
@property (nonatomic, nullable, copy) YDDeallocBlock deallocBlock;

- (instancetype)initWithBlock:(YDDeallocBlock)block;
@end

NS_ASSUME_NONNULL_END
