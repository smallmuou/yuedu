
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
 
 * @File:       LanguageManager.m
 * @Abstract:   语言管理器
 * @History:
 
 - 2013-03-27 创建 by xuwf
 */


#import "LanguageManager.h"


NSString* const LanguageManagerLanguageChangedNotify = @"LanguageManagerLanguageChangedNotify";
NSString* const LanguageManagerLanguageKey = @"LanguageManagerLanguageKey";

/**
 *@name:        languageTable
 *@Abstract:    语言表，列表所有支持的语言对应的名称，该名称必须与Localiztion对应；
 */

static struct LanguageItem {
    LanguageType    type;
    char*           name;   /* 需要与Apple一致 */
} const languageTable[] = {
    
    {LanguageTypeEnglish, "en"},
    {LanguageTypeSimpleChinese, "zh-Hans"},
    //other add here
    
    {LanguageTypeUnknown, NULL},
};

static LanguageType languageType(NSString* name)
{
    int i = 0;
    LanguageType type = LanguageTypeUnknown;
    const char* cname = [name UTF8String];
    
    if (!cname) return LanguageTypeUnknown;
    
    while (languageTable[i].type != LanguageTypeUnknown) {
        if (!strcmp(languageTable[i].name, cname)) {
            type = languageTable[i].type;
            break;
        }
        i++;
    }
    return type;
}

static NSString* languageName(LanguageType type)
{
    int i = 0;
    NSString *name = NULL;
    
    while (languageTable[i].type != LanguageTypeUnknown) {
        if (type == languageTable[i].type) {
            name = [NSString stringWithFormat:@"%s", languageTable[i].name];
        }
        i++;
    }
    return name;
}

@interface LanguageManager () {
    NSBundle* _bundle;
}
@end

@implementation LanguageManager

@synthesize type = _type;

SINGLETON_DEF(LanguageManager);

- (id)init {
    self  = [super init];
    if (self) {
        NSString* currentName = USER_CONFIG(LanguageManagerLanguageKey);
        if (!currentName) {//第一次使用系统语言
            currentName = [USER_CONFIG(@"AppleLanguages") objectAtIndex:0];
            if (languageType(currentName) == LanguageTypeUnknown) {
                currentName = @"en";
            }
            
            USER_SET_CONFIG(LanguageManagerLanguageKey, currentName);
        }
        [self setBundleForName:currentName];

    }
    return self;
}

- (void)setBundleForName:(NSString* )name
{
    NSString* path = [[ NSBundle mainBundle ] pathForResource:name ofType:@"lproj"];
    _bundle = [NSBundle bundleWithPath:path];
}

- (void)setType:(LanguageType)type {
    if (_type != type) {
        _type = type;
        [self setBundleForName:languageName(type)];

        POST_NOTIFY(LanguageManagerLanguageChangedNotify, nil, nil);
    }
}

- (NSString* )localizedStringForKey:(NSString* )key
{
    return [_bundle localizedStringForKey:key value:nil table:nil];
}

@end
