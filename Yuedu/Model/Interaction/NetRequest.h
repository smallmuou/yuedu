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
 
 * @File:       NetRequest.h
 * @Abstract:   网络请求基类
 * @History:
                
 - 2013-3-20 创建 by xuwf
 */

#import <Foundation/Foundation.h>
#import "NetRequestType.h"
#import "BaseOperation.h"

/*
 *@enum:         NetRequestError
 *@Abstract:     网络错误
 */
enum {
    NetRequestErrorUnconnectAble = 100,
    NetRequestErrorUnReachAble,
    NetRequestErrorTimeout,
};
typedef NSInteger NetRequestError;

extern NSString* const JSONRequestErrorDomain;
extern NSString* const UDPRequestErrorDomain;

/**
 *@protocol:    NetRequestDelegate
 *@Abstract:    定义网络请求代理接口，包括成功和失败接口
 */
@class NetRequest;
@protocol NetRequestDelegate <NSObject>
@optional
- (void)onNetRequest:(NetRequest*)request didSucceedWithResult:(NSDictionary*)result;
- (void)onNetRequest:(NetRequest*)request didFailWithError:(NSDictionary*)error;
- (void)onNetRequest:(NetRequest*)request didUpdatedWithInfo:(NSDictionary*)info;
@end


/**
 *@interface:   NetRequest
 *@Abstract:    网络请求基类，用于定义公共接口
 */
@interface NetRequest : BaseOperation
{
    id __weak       _delegate;
    NetRequestType  _type;
    NSString*       _serverIP;
    UInt16          _port;
    NSString*       _user;
    NSString*       _password;
    NSDictionary*   _info;
}

@property(nonatomic, weak) id <NetRequestDelegate>  delegate;
@property(nonatomic, assign) NetRequestType         type;
@property(nonatomic ,strong) NSString*              serverIP;
@property(nonatomic, assign) UInt16                 port;
@property(nonatomic ,strong) NSString*              user;
@property(nonatomic ,strong) NSString*              password;
@property(nonatomic, strong) NSDictionary*          info;
/**
 *@Function:    initWithType:withAddress:port:userInfo
 *@Abstract:    初始化
 *@Note:        当address为nil，则表示广播
 */
- (id)initWithType:(NetRequestType)type withAddress:(NSString*)address port:(UInt16)port userInfo:(NSDictionary*)info;

/**
 *@Function:    sendSynchronousRequest
 *@Abstract:    同步请求
 *@Note:        返回结果
 */
- (id)sendSynchronousRequest;

#pragma mark - 保护接口，只供子类调用，且子类不必重载
/**
 *@Function:    retry
 *@Abstract:    重试
 *@Note:        不供外部调用，子类不必重新实现
 */
- (void)retry;

- (void)didSuccessWithResult:(NSDictionary*)result;
- (void)didAuthFail;
- (void)didFail;
- (void)didUpdatedWithInfo:(NSDictionary*)info;
@end
