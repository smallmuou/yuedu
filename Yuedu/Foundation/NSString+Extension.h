//
//  NSString+Extension.h
//  Yuedu
//
//  Created by xuwf on 13-10-20.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)
+ (NSString* )stringWithSeconds:(int)seconds;
+ (NSString* )revertStringWithSeconds:(CGFloat)seconds;
- (NSString *)MD5;

@end
