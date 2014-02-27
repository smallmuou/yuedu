//
//  YDAlbumItem.h
//  Yuedu
//
//  Created by xuwf on 13-10-17.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDAlbumItem : NSObject <NSCopying, NSCoding> {
    NSInteger   _sid;
    NSInteger   _min;   /* minutes */
    NSInteger   _sec;   /* seconds */
    NSInteger   _listen;
}

@property (nonatomic, assign) NSInteger sid;
@property (nonatomic, assign) NSInteger min;
@property (nonatomic, assign) NSInteger sec;
@property (nonatomic, assign) NSInteger listen;

@end
