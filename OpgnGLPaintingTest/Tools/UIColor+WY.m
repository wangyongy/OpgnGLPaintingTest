//
//  UIColor+WY.m
//  WYPhotoEditor
//
//  Created by 王勇 on 2018/6/25.
//  Copyright © 2018年 王勇. All rights reserved.
//

#import "UIColor+WY.h"

#define WYValue(value)  MAX(0, MIN(1, value))

@implementation UIColor (WY)
/**
 获取UIColor对象的HSBA值
 */
- (NSArray *)HSBArray
{

    CGFloat h = 0.0,s = 0.0,b = 0.0,a = 0.0;
    
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    
    return @[@(WYValue(h)), @(WYValue(s)),@(WYValue(b)),@(WYValue(a))];
}
- (NSArray *)RGBArray
{
    CGFloat r = 0.0,g = 0.0,b = 0.0,a = 0.0;
    
    [self getRed:&r green:&g blue:&b alpha:&a];
    
    return @[@(WYValue(r)), @(WYValue(g)), @(WYValue(b)), @(WYValue(a))];
}
- (CGFloat)whiteValue
{
    CGFloat whiteValue = -1;
    
    NSArray * rgbArray = self.RGBArray;
    
    if (rgbArray.count == 4) {
        
        CGFloat red = [rgbArray[0] floatValue];
        CGFloat green = [rgbArray[1] floatValue];
        CGFloat blue = [rgbArray[2] floatValue];
        
        if (red == green && red == blue) {
            
            NSLog(@"%f,%f,%f",red,green,blue);
            
            whiteValue = [rgbArray[0] floatValue];
        }
    }

    return whiteValue;
}
@end









