//
//  PaintingView.h
//  OpgnGLPaintingTest
//
//  Created by 王勇 on 2018/10/30.
//  Copyright © 2018年 王勇. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "DrawModel.h"
//CLASS INTERFACES:

@interface PaintingView : UIImageView

/**  是否正在绘制  */
@property(nonatomic,assign)BOOL isDrawing;

/**  isDrawing值改变时的回调  */
@property(nonatomic,copy) void(^isDrawingBlock)(BOOL isDrawing);

/**
 初始化

 @param frame frame
 @param lineColorBlock 返回值为线条颜色的回调
 @param lineWidthBlock 返回值为线条宽度的回调
 @param isEraserBlock 返回值为是否是橡皮擦的回调
 @param drawPenTypeBlock 返回值为画笔类型的回调
 @return PaintingView
 */
- (instancetype)initWithFrame:(CGRect)frame lineColorBlock:(UIColor *(^)(void))lineColorBlock lineWidthBlock:(CGFloat(^)(void))lineWidthBlock isEraserBlock:(BOOL(^)(void))isEraserBlock drawPenTypeBlock:(DrawPenType(^)(void))drawPenTypeBlock;

/**  清除所有线段,并移除所有的point  */
- (void)clearLines;

/**  重新绘制  */
- (void)showLines;

/**  撤销上一步操作  */
- (void)undo;

@end
