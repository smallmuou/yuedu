
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
 
 * @File:       ArticleItem.m
 * @Abstract:   Article item of yuedu.fm
 * @History:
 
 -2013-10-15 创建 by xuwf
 */


#import "ArticleItem.h"

@implementation ArticleItem
@synthesize aid         = _aid;
@synthesize sid         = _sid;
@synthesize title       = _title;
@synthesize author      = _author;
@synthesize player      = _player;
@synthesize authorURL   = _authorURL;
@synthesize bgURL       = _bgURL;
@synthesize thumbURL    = _thumbURL;
@synthesize mp3URL      = _mp3URL;
@synthesize album       = _album;

- (NSString* )description {
    return [NSString stringWithFormat:@"aid=%d, sid=%d, title=%@, author=%@, player=%@, bg=%@, thumb=%@, mp3=%@, album=%@", _aid, _sid, _title, _author, _player, _bgURL, _thumbURL, _mp3URL, _album.description];
}

- (id)copyWithZone:(NSZone *)zone {
    ArticleItem* item = [[[self class] allocWithZone:zone] init];
    item.aid        = self.aid;
    item.sid        = self.sid;
    item.title      = [self.title copy];
    item.author     = [self.author copy];
    item.player     = [self.player copy];
    item.authorURL  = [self.authorURL copy];
    item.bgURL      = [self.bgURL copy];
    item.thumbURL   = [self.thumbURL copy];
    item.mp3URL     = [self.mp3URL copy];
    item.album      = [self.album copy];
    item->_flags      = self->_flags;
    return item;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.sid forKey:@"sid"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.author forKey:@"author"];
    [aCoder encodeObject:self.player forKey:@"player"];
    [aCoder encodeObject:self.authorURL forKey:@"authorURL"];
    [aCoder encodeObject:self.bgURL forKey:@"bgURL"];
    [aCoder encodeObject:self.thumbURL forKey:@"thumbURL"];
    [aCoder encodeObject:self.mp3URL forKey:@"mp3URL"];
    [aCoder encodeObject:self.album forKey:@"album"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.sid = [aDecoder decodeIntegerForKey:@"sid"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.author = [aDecoder decodeObjectForKey:@"author"];
        self.player = [aDecoder decodeObjectForKey:@"player"];
        self.authorURL = [aDecoder decodeObjectForKey:@"authorURL"];
        self.bgURL = [aDecoder decodeObjectForKey:@"bgURL"];
        self.thumbURL = [aDecoder decodeObjectForKey:@"thumbURL"];
        self.mp3URL = [aDecoder decodeObjectForKey:@"mp3URL"];
        self.album = [aDecoder decodeObjectForKey:@"album"];
    }
    return self;
}


- (NSString* )listen {
    return _album ? [NSString stringWithFormat:@"%d", _album.listen] : nil;
}

- (NSString* )duration {
    return _album ? [NSString stringWithFormat:@"%d:%02d", _album.min, _album.sec]: nil;
}

- (BOOL)existOnPlaylist {
    return _flags.existOnPlaylist;
}

- (void)setExistOnPlaylist:(BOOL)exist{
    _flags.existOnPlaylist = exist;
}

- (BOOL)favor {
    return _flags.favor;
}

- (void)setFavor:(BOOL)favor {
    _flags.favor = favor;
}

@end
