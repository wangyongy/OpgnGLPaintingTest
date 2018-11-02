//
//  UIView+Frame.h
//  CestbonHealthCheck-Native-iOS
//
//  Created by wangyong on 2018/5/23.
//  Copyright © 2018年 wangyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

@property(nonatomic,assign)CGFloat Width;
@property(nonatomic,assign)CGFloat Height;
@property(nonatomic,assign)CGFloat X;
@property(nonatomic,assign)CGFloat Y;
@property(nonatomic,assign)CGFloat CenterX;
@property(nonatomic,assign)CGFloat CenterY;
@property(nonatomic,assign)CGSize  Size;
@property(nonatomic,assign)CGPoint Origin;
@property(nonatomic,assign)CGFloat Bottom;
@property(nonatomic,assign)CGFloat Right;
@end
