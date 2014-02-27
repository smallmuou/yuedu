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
 
 * @File:       NetRequest.m
 * @Abstract:   网络请求基类
 * @History:
                
 - 2013-3-20 创建 by xuwf
 */

#import "NetRequest.h"

NSString* const NetRequestAuthKey = @"NetRequestAuthKey";
NSString* const NetRequestUsernameKey = @"NetRequestUsernameKey";
NSString* const NetRequestPasswordKey = @"NetRequestPasswordKey";
NSString* const NetRequestUUID = @"NetRequestUUID";

NSString* const RequestFailTypeIntKey = @"RequestFailTypeIntKey";
NSString* const NetRequestResultKey = @"NetRequestResultKey";
NSString* const NetRequestItemKey = @"NetRequestItemKey";
NSString* const NetRequestResultReverseKey = @"NetRequestResultReverseKey";

#define TRY_MAX_TIMES       (3) /* 重试3次 */

@interface NetRequest ()
{
    NSInteger _tryTimes;
}
@end

@implementation NetRequest
@synthesize delegate    = _delegate;
@synthesize type        = _type;
@synthesize serverIP    = _serverIP;
@synthesize port        = _port;
@synthesize user        = _user;
@synthesize password    = _password;
@synthesize info        = _info;

- (id)initWithType:(NetRequestType)type withAddress:(NSString*)address port:(UInt16)port userInfo:(NSDictionary*)info
{
    self = [super init];
    if (self) {
        _type = type;
        _tryTimes = 0;
        _serverIP = address;
        _port = port;
        _info = info;
        _user = [info objectForKey:NetRequestUsernameKey];
        _password = [info objectForKey:NetRequestPasswordKey];
        if (!_user) _user = @"";
        if (!_password) _password = @"";
    }
    return self;
}

- (id)sendSynchronousRequest {
    return nil;
}

- (void)retry
{
    if (_tryTimes < TRY_MAX_TIMES) {
        _tryTimes++;
        [self didStart];
    } else {
        [self didFail];
    }
}

- (void)didSuccessWithResult:(NSDictionary*)result
{
    if (_delegate
        && [_delegate respondsToSelector:@selector(onNetRequest:didSucceedWithResult:)]) {
        [_delegate onNetRequest:self didSucceedWithResult:result];
    }
    [self didFinish];
}

- (void)didAuthFail
{
    if (_delegate
        && [_delegate respondsToSelector:@selector(onNetRequest:didFailWithError:)]) {
        [_delegate onNetRequest:self didFailWithError:[NSDictionary dictionaryWithObjectsAndKeys:INT_NUMBER(RequestFailTypeAuthentication), RequestFailTypeIntKey, nil]];
    }
    [self didFinish];
}

- (void)didFail
{
    if (_delegate
        && [_delegate respondsToSelector:@selector(onNetRequest:didFailWithError:)]) {
        NSMutableDictionary* aResult = [NSMutableDictionary dictionaryWithObject:INT_NUMBER(RequestFailTypeError) forKey:RequestFailTypeIntKey];
        if (INFO_ITEM(_info)) {
            [aResult setValue:INFO_ITEM(_info) forKey:NetRequestResultKey];
        }
        [_delegate onNetRequest:self didFailWithError:aResult];
    }
    [self didFinish];
}

- (void)didUpdatedWithInfo:(NSDictionary*)info {
    if (_delegate && [_delegate respondsToSelector:@selector(onNetRequest:didUpdatedWithInfo:)]) {
        [_delegate onNetRequest:self didUpdatedWithInfo:info];
    }
}

@end
