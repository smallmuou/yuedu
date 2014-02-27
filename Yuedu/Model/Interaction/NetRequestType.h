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
 
 * @File:       NetRequestType.h
 * @Abstract:   网络请求类型
 * @History:
 
 - 2013-3-20 创建 by xuwf
 */

#define LOCAL_HTTP_PORT                         (8080)
#define LOCAL_UDP_PORT                          (8000)
#define HTTP_REQUEST_TIMEOUT                    (20.0f)

#pragma mark - NetRequestType
enum  {
    HTTPRequestTypeInvalid          = 0x0,
    
    HTTPRequestTypeChannel          = 0x1<<3,       /* 获取频道 */
    HTTPRequestTypeArticleList,                     /* 获取文章列表 */
    HTTPRequestTypeAlbum,                           /* 获取文章其他信息（播放时间，接听数） */
    HTTPRequestTypeArticleDetail,                   /* 获取具体内容（文章内容） */
    
    TASKRequestTypeArticleContent   = 0x01 << 4,    /* 获取音频内容 */
};

typedef NSInteger NetRequestType;

#define INFO_DICTIONARY(__item) (__item ? [NSDictionary dictionaryWithObjectsAndKeys:__item, NetRequestItemKey, nil]: nil)

#define INFO_ITEM(__dict) ([__dict objectForKey:NetRequestItemKey])

#define RESULT_DICTIONARY(__item) (__item ? [NSDictionary dictionaryWithObjectsAndKeys:__item, NetRequestResultKey, nil] : nil)

#define RESULT_DICTIONARY_1(__item, __reverse) (__item ? [NSDictionary dictionaryWithObjectsAndKeys:__item, NetRequestResultKey, __reverse, NetRequestResultReverseKey, nil] : nil)

#define RESULT_ITEM(__dict) ([__dict objectForKey:NetRequestResultKey])
#define RESULT_REVERSE(__dict) ([__dict objectForKey:NetRequestResultReverseKey])

#pragma mark - Keys
extern NSString* const WEBRequestAuthMac;

extern NSString* const NetRequestAuthKey;
extern NSString* const NetRequestUsernameKey;
extern NSString* const NetRequestPasswordKey;
extern NSString* const NetRequestUUID;
extern NSString* const NetRequestItemKey;
extern NSString* const NetRequestResultKey;
extern NSString* const NetRequestResultReverseKey;

#pragma mark - error
enum {
    RequestFailTypeTimeOut = 0,
    RequestFailTypeAuthentication,
    RequestFailTypeError,
};

extern NSString *const RequestFailTypeIntKey;
extern NSString *const UDPRequestServerIPKey;

#pragma mark - Instruction
#define INSTRCTION_MAX_SIZE         (64)
/**
 *@Function:    instructionType
 *@Abstract:    根据给的指令获取请求类型
 *@Param:
 cmd[in]     一级指令
 subcmd[in]  二级指令
 *@Return:      返回请求类型，非法返回JSONRequestTypeInvalid
 *@Histroy:
 - 2013-03-21 create by xuwf
 
 */
NetRequestType instructionType(const char* cmd, const char* subcmd);

/**
 *@Function:    instructionCMD
 *@Abstract:    根据请求类型获取指令
 *@Param:
 type[in]    请求类型
 cmd[out]    一级指令
 subcmd[out] 二级指令
 *@Return:      成功返回0，失败返回-1
 *@Note:
 cmd和subcmd 最好分配INSTRCTION_MAX_SIZE大小空间
 *@Histroy:
 - 2013-03-21 create by xuwf
 
 */
int instructionCMD(NetRequestType type, char* cmd, char* subcmd);
