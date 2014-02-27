
/*!
 @header    CustomViews.m
 用户自定义Views，在CustomViews.xib
 
 @copyright Copyright (c) 2013,福建星网视易信息系统有限公司. All rights reserved.
 
 @author    xuwf
 @updated   2013-03-27
 */

#import "CustomViews.h"

@implementation CustomViews
+ (id)customViewsWithTag:(CustomViewTag )tag {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CustomViews" owner:self options:nil];
    for (UIView *view in array) {
        if (tag == view.tag) {
            return view;
        }
    }
    return nil;
}

@end
