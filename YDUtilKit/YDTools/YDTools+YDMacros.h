//
//  Header.h
//  YDUtilKit
//
//  Created by 王远东 on 2024/4/3.
//

#ifdef __OBJC__

// The __FILE__ lastPathComponent
#ifndef __FILENAME__
#define __FILENAME__ [[[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lastPathComponent] UTF8String]
#endif

#ifndef AT_SYNCHRONIZED
#define AT_SYNCHRONIZED_BEGIN(obj)  @synchronized(obj){
#define AT_SYNCHRONIZED_END         }
#endif//AT_SYNCHRONIZED

#ifndef AT_SYNCHRONIZED_SELF
#define AT_SYNCHRONIZED_SELF_BEGIN  @synchronized(self){
#define AT_SYNCHRONIZED_SELF_END    }
#endif//AT_SYNCHRONIZED_SELF

#endif // __OBJC__
