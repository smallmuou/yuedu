//
//  TaskRequest.m
//  Yuedu
//
//  Created by xuwf on 13-10-29.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "TaskRequest.h"

@interface TaskRequest () {
    YDTaskItem*             _task;
    NSURLConnection*        _connection;
    FILE*                   _fp;
    
    int64_t                 _lastUpdate;
    int64_t                 _threshold;
}
@end

@implementation TaskRequest
- (id)initWithType:(NetRequestType)type withAddress:(NSString*)address port:(UInt16)port userInfo:(NSDictionary*)info
{
    self = [super initWithType:type withAddress:address port:port userInfo:info];
    if (self) {
        _task = INFO_ITEM(info);
    }
    return self;
}

- (void)didStart {
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_task.article.mp3URL]];
    [request setTimeoutInterval:HTTP_REQUEST_TIMEOUT];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",_task.recvLength] forHTTPHeaderField:@"Range"];
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (_connection == connection) {
        [self retry];
    }
}


#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (_connection == connection) {
        fwrite(data.bytes, 1, data.length, _fp);
        _task.recvLength += data.length;
        
        /* 防止太频繁更新 */
        if ((_task.recvLength-_lastUpdate) > _threshold) {
            [self didUpdatedWithInfo:RESULT_DICTIONARY(_task)];
            _lastUpdate = _task.recvLength;            
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (_connection == connection) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSInteger code = [(NSHTTPURLResponse *)response statusCode];
            if (code == 401) {
                [self didAuthFail];
            } else {
                _task.totalLength = [(NSHTTPURLResponse *)response expectedContentLength];
                [self didUpdatedWithInfo:RESULT_DICTIONARY(_task)];
                _fp = fopen(_task.localPath.UTF8String, "wb");
                _threshold = _task.totalLength*0.01;/*1%更新一次*/
                if (!_fp) [self didFail];
            }
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (_connection == connection) {
        if (_fp) fclose(_fp);
        [self didUpdatedWithInfo:RESULT_DICTIONARY(_task)];

        [self didSuccessWithResult:RESULT_DICTIONARY(_task)];
    }
}

@end
