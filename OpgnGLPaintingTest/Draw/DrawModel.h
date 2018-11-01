//
//  DrawModel.h
//  CloudTeachers
//
//  Created by xinhao on 2018/9/29.
//  Copyright © 2018年 yubay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class DrawModel;

/** 点的状态 */
typedef NS_OPTIONS(NSUInteger, DrawPointStatus) {
    /** 开始 */
    kDrawPointStatusStart = 1,
    /** 移动 */
    kDrawPointStatusMove = 2,
    /** 结束 */
    kDrawPointStatusEnd = 3,
};

/** 画笔类型 */
typedef NS_OPTIONS(NSInteger, DrawPenType) {
    /** 曲线 default */
    kDrawPenTypeCurve = 0,
    /** 直线 */
    kDrawPenTypeStraight = 1,
    /** 矩形 */
    kDrawPenTypeRectangle = 2,
    /** 圆形 */
    kDrawPenTypeCircular = 3,
};

@interface DrawPointModel : NSObject

/** 线条宽度 默认为1 */
@property (nonatomic, assign) CGFloat lineWidth;
/** 绘制笔颜色值 */
@property (nonatomic, strong) UIColor * lineColor;
/** 绘制笔类型 默认为曲线 */
@property (nonatomic, assign) DrawPenType penType;
/** 是否是橡皮擦 */
@property(nonatomic,assign) BOOL isEraser;
/** 该点x轴坐标值 = 当前获取的该点x/当前视图的对角线长度 */
@property (nonatomic, assign) CGFloat x;
/** 该点y轴坐标值 = 当前获取的该点y/当前视图的对角线长度*/
@property (nonatomic, assign) CGFloat y;
/** 该点的状态类型 */
@property (nonatomic, assign) DrawPointStatus pointStatus;

- (instancetype)initWithDrawModel:(DrawModel *)aModel;

@end

@interface DrawModel : NSObject

/** 线条宽度 默认为1 */
@property (nonatomic, assign) CGFloat lineWidth;
/** 绘制笔颜色值 */
@property (nonatomic, strong) UIColor * lineColor;
/** 绘制笔类型 默认为曲线 */
@property (nonatomic, assign) DrawPenType penType;
/** 是否是橡皮擦 */
@property(nonatomic,assign) BOOL isEraser;

/** 该操作下的所有点 */
@property (nonatomic, strong) NSMutableArray <DrawPointModel *>*pointsArray;

@end
