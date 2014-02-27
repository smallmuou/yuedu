/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       BaseOperation.h
 * @Abstract:   对NSOperation扩展，实现OperationQueue的自动执行
 * @History:
                
 - 2013-3-20 创建 by xuwf
 */

#import <Foundation/Foundation.h>

@interface BaseOperation : NSOperation
{
    BOOL    _done;
    BOOL    _executing;
    BOOL    _cancelled;
}

- (void)didStart;
- (void)didFinish;

@end
