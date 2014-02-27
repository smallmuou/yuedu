//
//  Header.h
//  superio
//
//  Created by luyf on 12-10-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef _SUPERIO_H_
#define _SUPERIO_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <sys/types.h>

#define SIO_RDONLY  1
#define SIO_WRONLY  2
#define SIO_RDWR    (SIO_RDONLY|SIO_WRONLY)

typedef struct URLContext SIOContext;
int sio_open(SIOContext **h, const char *url, int flags);
int sio_close(SIOContext *h);
int sio_read(SIOContext *h, unsigned char *buf, int size);
int sio_write(SIOContext *h, const unsigned char *buf, int size);
int64_t sio_seek(SIOContext *h, int64_t pos, int whence);
int64_t sio_filesize(SIOContext *h);
    
#ifdef __cplusplus
}
#endif
#endif
