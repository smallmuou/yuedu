
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
 
 * @File:       LanguageManager.h
 * @Abstract:   语言管理器
 * @History:
 
 - 2013-03-27 创建 by xuwf
 */


#import <Foundation/Foundation.h>


#define LOCALIZE(__key) [SINGLETON_CALL(LanguageManager) localizedStringForKey:__key]

extern NSString* const LanguageManagerLanguageChangedNotify;
enum {
    LanguageTypeUnknown = 0,
    LanguageTypeEnglish,
    LanguageTypeSimpleChinese,
};
typedef NSInteger LanguageType;


@interface LanguageManager : NSObject {
    LanguageType _type;
}
@property (nonatomic, assign)LanguageType type;

SINGLETON_AS(LanguageManager);


- (NSString* )localizedStringForKey:(NSString* )key;

@end
