
/*!
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included
 in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 * @File:       ChannelItem
 * @Abstract:   Channel for yuedu.fm
 * @History:
 
 -2013-10-15 创建 by xuwf
 */

#import "ChannelItem.h"

@implementation ChannelItem
@synthesize name = _name;
@synthesize offset = _offset;
@synthesize count = _count;

- (NSString* )description {
    return [NSString stringWithFormat:@"Channel:%@, offset=%d, count=%d", _name, _offset, _count];
}

- (id)copyWithZone:(NSZone *)zone {
    ChannelItem* item = [[[self class] allocWithZone:zone] init];
    item.name   = [self.name copy];
    item.offset = self.offset;
    item.count  = self.count;
    return item;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInteger:self.offset forKey:@"offset"];
    [aCoder encodeInteger:self.count forKey:@"count"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.offset = [aDecoder decodeIntegerForKey:@"offset"];
        self.count = [aDecoder decodeIntegerForKey:@"count"];
    }
    return self;
}


@end
