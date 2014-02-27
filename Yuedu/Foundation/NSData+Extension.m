//
//  NSData+Extension.m
//  Yuedu
//
//  Created by xuwf on 13-10-23.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "NSData+Extension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (Extension)
- (NSData *)MD5
{
	unsigned char md5Result[CC_MD5_DIGEST_LENGTH + 1];
	CC_MD5( [self bytes], [self length], md5Result );
	
	NSMutableData * retData = [[NSMutableData alloc] init];
	if ( nil == retData )
		return nil;
	
	[retData appendBytes:md5Result length:CC_MD5_DIGEST_LENGTH];
	return retData;
}

@end
