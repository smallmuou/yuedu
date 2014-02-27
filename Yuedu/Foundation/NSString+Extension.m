//
//  NSString+Extension.m
//  Yuedu
//
//  Created by xuwf on 13-10-20.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)
+ (NSString* )stringWithSeconds:(int)seconds {
    if (seconds < 0) seconds = 0;
    
    int s = (int)seconds%60;
    int min = seconds/60;
    int m = min%60;
    int h = min/60;
    
    NSString* str = nil;
    if (h) {
        str = [NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s];
    } else {
        str = [NSString stringWithFormat:@"%02d:%02d", m, s];
    }
    return str;
}

+ (NSString* )revertStringWithSeconds:(CGFloat)seconds {
    return [NSString stringWithFormat:@"-%@", [NSString stringWithSeconds:seconds]];
}

- (NSString *)MD5
{
	NSData * value;
	
	value = [NSData dataWithBytes:[self UTF8String] length:[self length]];
	value = [value MD5];
    
	if (value) {
		char			tmp[16];
		unsigned char *	hex = (unsigned char *)malloc( 2048 + 1 );
		unsigned char *	bytes = (unsigned char *)[value bytes];
		unsigned long	length = [value length];
		
		hex[0] = '\0';
		
		for ( unsigned long i = 0; i < length; ++i )
		{
			sprintf( tmp, "%02X", bytes[i] );
			strcat( (char *)hex, tmp );
		}
		
		NSString * result = [NSString stringWithUTF8String:(const char *)hex];
		free( hex );
		return result;
	}
	else
	{
		return nil;
	}
}

@end
