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
 
 * @File:       HTTPRequest.m
 * @Abstract:   HTTP请求
 * @History:
                
 - 2013-3-20 创建 by xuwf
 */

#import "HTTPRequest.h"

#define DEFAULT_PORT            (80)

@interface HTTPRequest() <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSString*               _url;
    NSURLRequest*           _request;
    NSURLConnection*        _connection;
    NSTimer*                _timer;
    NSMutableData*          _receiveData;
    long long               _receiveLength;
}

@end

@implementation HTTPRequest

- (id)initWithType:(NetRequestType)type withAddress:(NSString*)address port:(UInt16)port userInfo:(NSDictionary*)info
{
    port = port ? port : DEFAULT_PORT;
    self = [super initWithType:type withAddress:address port:port userInfo:info];
    if (self) {
        _request = [self requestFactory];
    }
    
    return self;
}

- (NSURLRequest* )requestFactory  {
    switch (_type) {
        case HTTPRequestTypeChannel:
            _url = [NSString stringWithFormat:@"http://%@:%d", _serverIP, _port];
            break;
        case HTTPRequestTypeArticleList:
            _url = [NSString stringWithFormat:@"http://%@:%d/?data=playlist", _serverIP, _port];
            break;
        case HTTPRequestTypeAlbum:
            _url = [NSString stringWithFormat:@"http://%@:%d/?data=album", _serverIP, _port];
            break;
        case HTTPRequestTypeArticleDetail:{
            ArticleItem* item = INFO_ITEM(_info);
            _url = [NSString stringWithFormat:@"http://%@:%d/?data=item&item_id=%d", _serverIP, _port, item.aid];
            break;
        }
        default:
            break;
    }
    if (_url) {
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        if (HTTPRequestTypeChannel != _type) {
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
        
        [request setHTTPMethod:@"GET"];
        
        return request;
    } else {
        return nil;
    }
}

- (void)didStart
{
    if (_request) {
        _connection = [NSURLConnection connectionWithRequest:_request delegate:self];
        _timer = [NSTimer scheduledTimerWithTimeInterval:HTTP_REQUEST_TIMEOUT target:self selector:@selector(timeout:) userInfo:nil repeats:NO];        
    } else {
        [self didFail];
    }
}

#pragma mark - Timer
- (void)invalidateTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)timeout:(id)timer
{
    if (_timer == timer) {
        [self retry];
    }
}




#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (_connection == connection) {
        [self invalidateTimer];
        [self retry];
    }
}


#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (_connection == connection) {
        [_receiveData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (_connection == connection) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSInteger code = [(NSHTTPURLResponse *)response statusCode];
            if (code == 401) {
                [self didAuthFail];
            } else {
                [self invalidateTimer];
                _receiveData = [[NSMutableData alloc] init];
                _receiveLength = [(NSHTTPURLResponse *)response expectedContentLength];
            }
        }
    }
}

- (void)parseReceiveDataInBackground
{
    NSDictionary *result = [self parseReceiveData:_receiveData];
    
    [self performSelectorOnMainThread:@selector(presentResultOnMainThread:) withObject:result waitUntilDone:NO];
}

- (void)presentResultOnMainThread:(NSDictionary *)result
{
    [self didSuccessWithResult:result];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (_connection == connection) {
        [self performSelectorInBackground:@selector(parseReceiveDataInBackground) withObject:nil];
    }
}

- (NSDictionary* )parseReceiveData:(NSData *)data {
    NSDictionary* result = nil;
    
    switch (_type) {
        case HTTPRequestTypeChannel: {
            TFHpple* parser = [[TFHpple alloc] initWithHTMLData:data];
            NSArray *elements  = [parser searchWithXPathQuery:@"//div[@class='album']/ul/li/a"];
            NSMutableArray* channels = [NSMutableArray array];
            for (TFHppleElement* ele in elements) {
                ChannelItem* item = [[ChannelItem alloc] init];
                item.name = ele.text;
                int off = 0, count = 0;
                const char* rel = [[ele.attributes objectForKey:@"rel"] UTF8String];
                if (rel && 2 == sscanf(rel, "%d:%d", &count, &off)) {
                    item.offset = off;
                    item.count = count;
                }
                [channels addObject:item];
            }
            result = RESULT_DICTIONARY(channels);
            break;
        }
        case HTTPRequestTypeArticleList: {
            NSInteger aid = 0;/* 序列号（从0开始） */
            NSMutableArray* articles = [NSMutableArray array];
            NSArray* items = [[data objectFromJSONData] objectForKey:@"list"];
            for (NSDictionary* item in items) {
                ArticleItem* article = [[ArticleItem alloc] init];
                article.aid = aid++;
                article.sid = [[item objectForKey:@"sid"] integerValue];
                article.title = [item objectForKey:@"title"];
                article.author = [item objectForKey:@"author"];
                article.authorURL = [item objectForKey:@"author_url"];
                article.player = [item objectForKey:@"player"];
                article.bgURL = [item objectForKey:@"bg"];
                article.thumbURL = [item objectForKey:@"img"];
                article.mp3URL = [item objectForKey:@"mp3"];
                [articles addObject:article];
            }
            result = RESULT_DICTIONARY(articles);
            break;
        }
        case HTTPRequestTypeAlbum: {
            NSMutableArray* albums = [NSMutableArray array];
            NSArray* items = [[data objectFromJSONData] objectForKey:@"album"];
            for (NSDictionary* item in items) {
                YDAlbumItem* album = [[YDAlbumItem alloc] init];
                album.sid = [[item objectForKey:@"sid"] integerValue];
                album.min = [[item objectForKey:@"min"] integerValue];
                album.sec = [[item objectForKey:@"sec"] integerValue];
                album.listen = [[item objectForKey:@"listen"] integerValue];
                [albums addObject:album];
            }
            result = RESULT_DICTIONARY(albums);
            break;
        }
        case HTTPRequestTypeArticleDetail: {
            NSArray* items = [[data objectFromJSONData] objectForKey:@"item"];
            if ([items count]) {
                NSDictionary* item = [items objectAtIndex:0];
                ArticleItem* article = INFO_ITEM(_info);
                NSString* sid = [NSString stringWithFormat:@"%d", article.sid];
                result = RESULT_DICTIONARY_1([item objectForKey:@"text"], sid);
            }
            break;
        }
        default:
            break;
    }
    return result;
}

@end
