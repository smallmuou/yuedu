
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
 
 * @File:       ArticleItem.h
 * @Abstract:   Article item of yuedu.fm
 * @History:
 
 -2013-10-15 创建 by xuwf
 */

#import <Foundation/Foundation.h>

@class YDAlbumItem;
@interface ArticleItem : NSObject <NSCopying, NSCoding> {
    NSInteger       _aid;       /* 序号,用于请求具体内容 */
    NSInteger       _sid;
    NSString*       _title;
    NSString*       _author;
    NSString*       _player;
    NSString*       _authorURL;
    NSString*       _bgURL;
    NSString*       _thumbURL;
    NSString*       _mp3URL;
    YDAlbumItem*    _album;     /* 存储播放时间、接听数 */
    struct{
        unsigned int existOnPlaylist:1; /* 是否在播放列表 */
        unsigned int favor:1;           /* 是否收藏 */
    }_flags;
}
@property (nonatomic, assign) NSInteger aid;
@property (nonatomic, assign) NSInteger sid;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* author;
@property (nonatomic, strong) NSString* player;
@property (nonatomic, strong) NSString* authorURL;
@property (nonatomic, strong) NSString* bgURL;
@property (nonatomic, strong) NSString* thumbURL;
@property (nonatomic, strong) NSString* mp3URL;
@property (nonatomic, strong) YDAlbumItem* album;

@property (nonatomic, readonly) NSString* listen;
@property (nonatomic, readonly) NSString* duration;

@property (nonatomic) BOOL existOnPlaylist;
@property (nonatomic) BOOL favor;

@end
