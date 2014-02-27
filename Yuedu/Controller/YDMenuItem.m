//
//  YDMenuItem.m
//  Yuedu
//
//  Created by xuwf on 13-10-16.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDMenuItem.h"

@interface YDMenuItem () {
    NSString* _name;
    NSArray* _children;
    NSObject* _data;
}

@end

@implementation YDMenuItem
@synthesize name = _name;
@synthesize children = _children;
@synthesize data = _data;

- (id)initWithName:(NSString *)name children:(NSArray *)children {
    self = [super init];
    if (self) {
        self.children = children;
        self.name = name;
    }
    return self;
}

+ (id)dataObjectWithName:(NSString *)name children:(NSArray *)children {
    return [[self alloc] initWithName:name children:children];
}
@end
