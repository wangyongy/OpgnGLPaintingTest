//
//  UIView+Frame.m
//  CestbonHealthCheck-Native-iOS
//
//  Created by wangyong on 2018/5/23.
//  Copyright © 2018年 wangyong. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

#pragma mark - get
- (CGFloat)Width
{
    return self.frame.size.width;
}
- (CGFloat)Height
{
    return self.frame.size.height;
}
- (CGFloat)X
{
    return self.frame.origin.x;
}
- (CGFloat)Y
{
    return self.frame.origin.y;
}
- (CGFloat)CenterX
{
    return self.center.x;
}
- (CGFloat)CenterY
{
    return self.center.y;
}
- (CGSize)Size
{
    return self.frame.size;
}
- (CGPoint)Origin
{
    return self.frame.origin;
}
- (CGFloat)Bottom
{
    return self.Y + self.Height;
}
- (CGFloat)Right
{
    return self.X + self.Width;
}
#pragma mark - set
- (void)setWidth:(CGFloat)Width
{
    CGRect frame = self.frame;
    frame.size.width = Width;
    self.frame = frame;
}
- (void)setHeight:(CGFloat)Height
{
    CGRect frame = self.frame;
    frame.size.height = Height;
    self.frame = frame;
}
- (void)setX:(CGFloat)X
{
    CGRect frame = self.frame;
    frame.origin.x = X;
    self.frame = frame;
}
- (void)setY:(CGFloat)Y
{
    CGRect frame = self.frame;
    frame.origin.y = Y;
    self.frame = frame;
}
- (void)setCenterX:(CGFloat)CenterX
{
    CGPoint center = self.center;
    center.x = CenterX;
    self.center = center;
}
- (void)setCenterY:(CGFloat)CenterY
{
    CGPoint center = self.center;
    center.y = CenterY;
    self.center = center;
}
- (void)setSize:(CGSize)Size
{
    CGRect frame = self.frame;
    frame.size = Size;
    self.frame = frame;
}
- (void)setOrigin:(CGPoint)Origin
{
    CGRect frame = self.frame;
    frame.origin = Origin;
    self.frame = frame;
}
- (void)setBottom:(CGFloat)Bottom
{
}
- (void)setRight:(CGFloat)Right
{
}
@end
