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
 
 * @File:       NetManager.m
 * @Abstract:   网络管理器
                1、实时判断网络状态
                2、提供与智能控制主机的交互接口
                3、负责智能控制主机反馈数据的分发
 * @History:
 
 - 2013-3-20 创建 by xuwf
 */

#import "NetManager.h"
#import "HTTPRequest.h"
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <sys/time.h>

/* HTTP 处理最大并行数 */
#define MAX_CONCURRENT_OPERATIONCOUNT       (3)
#define SERVER_IP                           (@"yuedu.fm")

NSString* const NetManagerInteractionDidSuccessNotification = @"NetManagerInteractionDidSuccessNotification";
NSString* const NetManagerInteractionAuthFailNotfication = @"NetManagerInteractionAuthFailNotfication";
NSString* const NetManagerInteractionFailNotification = @"NetManagerInteractionFailNotification";
NSString* const NetManagerConnectDidSuccessNotification = @"NetManagerInteractionDidSuccessNotification";
NSString* const NetManagerConnectDidFailNotification = @"NetManagerInteractionDidFailNotification";


@interface NetManager() <NetRequestDelegate> {
    NSOperationQueue*   _requestQueue;
}

@end

@implementation NetManager
SINGLETON_DEF(NetManager);

- (id)init {
    self = [super init];
    if (self) {
        _requestQueue = [[NSOperationQueue alloc] init];
        [_requestQueue setMaxConcurrentOperationCount:MAX_CONCURRENT_OPERATIONCOUNT];
    }
    
    return self;
}

- (void)connect {
    NSLog(@"Start UDP Server:%d", LOCAL_UDP_PORT);
}

- (void)disconnect {
    NSLog(@"Stop UDP Server:%d", LOCAL_UDP_PORT);
}

- (id)interaction:(NetRequestType)type userInfo:(NSDictionary *)info {
    HTTPRequest* request = [[HTTPRequest alloc] initWithType:type withAddress:SERVER_IP port:80 userInfo:info];
    request.delegate = self;
    [_requestQueue addOperation:request];
    return request;
}

#pragma mark - NetRequestDelegate
- (void)onNetRequest:(NetRequest *)request didSucceedWithResult:(NSDictionary *)result {    
    [[NSNotificationCenter defaultCenter] postNotificationName:NetManagerInteractionDidSuccessNotification object:request userInfo:result];
}

- (void)onNetRequest:(NetRequest *)request didFailWithError:(NSDictionary *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NetManagerInteractionFailNotification object:request];
}

@end



