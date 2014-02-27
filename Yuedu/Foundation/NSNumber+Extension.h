/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       NSNumber+Extension.h
 * @Abstract:   NSNumber宏
 * @History:
                
 - 2013-3-22 创建 by xuwf
 */

#import <Foundation/Foundation.h>

/*******************************************************************************
 * number
 ******************************************************************************/
#undef  BYTE_NUMBER
#define BYTE_NUMBER( __x )          [NSNumber numberWithUnsignedChar:(unsigned char)__x]

#undef  CHAR_NUMBER
#define CHAR_NUMBER( __x )          [NSNumber numberWithChar:(char)__x]

#undef  USHORT_NUMBER
#define USHORT_NUMBER( __x )        [NSNumber numberWithUnsignedShort:(unsigned short)__x]

#undef	INT_NUMBER
#define INT_NUMBER( __x )			[NSNumber numberWithInt:(NSInteger)__x]

#undef	UINT_NUMBER
#define UINT_NUMBER( __x )			[NSNumber numberWithUnsignedInt:(NSUInteger)__x]

#undef	FLOAT_NUMBER
#define	FLOAT_NUMBER( __x )			[NSNumber numberWithFloat:(float)__x]

#undef  DOUBLE_NUMBER
#define DOUBLE_NUMBER( __x )        [NSNumber numberWithDouble:(double)__x]


#undef  BOOL_NUMBER
#define BOOL_NUMBER( __x )          [NSNumber numberWithBool:(BOOL)__x]


#undef  NSINT_NUMBER
#define NSINT_NUMBER( __x )         [NSNumber numberWithInteger:(NSInteger)__x]

/*******************************************************************************
 * value
 ******************************************************************************/
#undef  BYTE_VALUE
#define BYTE_VALUE( __n )           [__n unsignedCharValue]

#undef  CHAR_VALUE
#define CHAR_VALUE( __n )           [__n charValue]

#undef  USHORT_VALUE
#define USHORT_VALUE( __n )         [__n unsignedShortValue]

#undef  SHORT_VALUE
#define SHORT_VALUE( __n )         [__n shortValue]

#undef  INT_VALUE
#define INT_VALUE( __n )            [__n intValue]

#undef  UINT_VALUE
#define UINT_VALUE( __n )           [__n unsignedIntegerValue]

#undef  FLOAT_VALUE
#define FLOAT_VALUE( __n )          [__n floatValue]

#undef  DOUBLE_VALUE
#define DOUBLE_VALUE( __n )         [__n doubleValue]

#undef  BOOL_VALUE
#define BOOL_VALUE( __n )           [__n boolValue]

#undef  NSINT_VALUE
#define NSINT_VALUE( __n )          [__n integerValue]


/*******************************************************************************
 * Extension
 ******************************************************************************/
@interface NSNumber (Extension)

@end
