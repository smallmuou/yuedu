/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       BaseOperation.m
 * @Abstract:   对NSOperation扩展，实现OperationQueue的自动执行
 * @History:
                
 - 2013-3-20 创建 by xuwf
 */

#import "BaseOperation.h"

@implementation BaseOperation

- (void)didStart
{
    
}

- (void)didFinish
{
    [self willChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"isFinished"];
	
	_done = YES;
	_executing = NO;
    
	[self didChangeValueForKey:@"isExecuting"];
	[self didChangeValueForKey:@"isFinished"];
}

- (void)start
{
    //必须放到主线程，否则无法收到消息
    if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(start)
							   withObject:nil
                            waitUntilDone:NO];
		
		return;
	}
    
    [self willChangeValueForKey:@"isExecuting"];
	
	_executing = YES;
    [self didStart];
	
	[self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isConcurrent {
	return YES;
}

- (BOOL)isExecuting {
	return _executing;
}

- (BOOL)isFinished {
	return _done;
}

- (BOOL)isCancelled {
	return _cancelled;
}

@end
