//
//  YDAlbumItem.m
//  Yuedu
//
//  Created by xuwf on 13-10-17.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDAlbumItem.h"

@implementation YDAlbumItem
@synthesize sid = _sid;
@synthesize min = _min;
@synthesize sec = _sec;
@synthesize listen = _listen;

- (NSString* )description {
    return [NSString stringWithFormat:@"sid=%d, min=%d, sec=%d, listen=%d",
            _sid, _min, _sec, _listen];
}


- (id)copyWithZone:(NSZone *)zone {
    YDAlbumItem* item = [[[self class] allocWithZone:zone] init];
    item.sid    = self.sid;
    item.min    = self.min;
    item.sec    = self.sec;
    item.listen = self.listen;
    return item;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.sid forKey:@"sid"];
    [aCoder encodeInteger:self.min forKey:@"min"];
    [aCoder encodeInteger:self.sec forKey:@"sec"];
    [aCoder encodeInteger:self.listen forKey:@"listen"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.sid = [aDecoder decodeIntegerForKey:@"sid"];
        self.min = [aDecoder decodeIntegerForKey:@"min"];
        self.sec = [aDecoder decodeIntegerForKey:@"sec"];
        self.listen = [aDecoder decodeIntegerForKey:@"listen"];
    }
    return self;
}


@end
