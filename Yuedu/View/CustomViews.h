
/*!
 @header    CustomViews.h
 用户自定义Views，在CustomViews.xib
 
 @copyright Copyright (c) 2013,福建星网视易信息系统有限公司. All rights reserved.
 
 @author    xuwf
 @updated   2013-03-27
 */

#import <Foundation/Foundation.h>

@interface CustomViews : NSObject

enum {
    CustomViewTagUnknown = 0,
    CustomViewSubMenuCell,
    CustomViewArticleCell,
    CustomViewBriefArticleCell,
    CustomViewTaskCell,
    CustomViewTaskSectionHeader,
};

typedef NSInteger CustomViewTag;

/*!
 获取CustomViews.xib中tag对应的View
 @param     tag
 CustomViews.xib 设定各个view的tag，定义如上
 
 @return    返回对应的view
 */
+ (id)customViewsWithTag:(CustomViewTag )tag;
@end
