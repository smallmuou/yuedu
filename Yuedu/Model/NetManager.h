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
 
 * @File:       NetManager.h
 * @Abstract:   网络管理器
                1、实时判断网络状态
                2、提供与智能控制主机的交互接口
                3、负责智能控制主机反馈数据的分发
 * @History:

 - 2013-3-20 创建 by xuwf
 */

#import <Foundation/Foundation.h>
#import "NetRequest.h"

extern NSString* const NetManagerInteractionDidSuccessNotification;
extern NSString* const NetManagerInteractionAuthFailNotfication;
extern NSString* const NetManagerInteractionFailNotification;

@interface NetManager : NSObject {
}

SINGLETON_AS(NetManager);

/* keys see NetRequestType.h */
- (id)interaction:(NetRequestType)type userInfo:(NSDictionary *)info;

- (void)connect;

- (void)disconnect;

@end


