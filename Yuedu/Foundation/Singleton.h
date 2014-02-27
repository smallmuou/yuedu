/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       Foundation.h
 * @Abstract:   单例模式，宏定义
 * @History:
                
 - 2013-3-22 创建 by xuwf
 */

#import <Foundation/Foundation.h>

#undef	SINGLETON_AS
#define SINGLETON_AS( __class ) \
+ (__class *)sharedInstance;

#undef	SINGLETON_DEF
#define SINGLETON_DEF( __class ) \
+ (__class *)sharedInstance \
{ \
    static dispatch_once_t once; \
    static __class * __singleton__; \
    dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
    return __singleton__; \
}

#undef SINGLETON_CALL
#define SINGLETON_CALL( __class ) [__class sharedInstance]