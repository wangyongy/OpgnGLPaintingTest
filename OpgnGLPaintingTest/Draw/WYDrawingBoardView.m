//
//  WYDrawingBoardView.m
//  WYDrawingBoard
//
//  Created by 王勇 on 2018/7/2.
//  Copyright © 2018年 王勇. All rights reserved.
//

#import "WYDrawingBoardView.h"
#import "WYSelectView.h"
#import "PaintingView.h"
#import "WYMain.h"

@interface WYDrawingBoardView ()

@property (nonatomic, strong) WYSelectView * selectView;

@property (nonatomic, strong) PaintingView * drawView;

@end

@implementation WYDrawingBoardView

#pragma mark - public
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupViews];
    }
    return self;
}
- (void)clearLines
{
    [_drawView clearLines];
}

- (void)undo
{
    [_drawView undo];
}
#pragma mark - private
- (void)setupViews
{
    
    WS(weakSelf)
    
    _selectView = [[WYSelectView alloc] initWithFrame:CGRectMake(0, self.Height - self.Width/10 - 100, self.Width, self.Width/10 + 100)];
    
    _selectView.revokeBlock = ^{
        
        ST(strongSelf)
        
        [strongSelf -> _drawView undo];
    };
    
    _drawView = [[PaintingView alloc] initWithFrame:self.bounds lineColorBlock:^UIColor *{

        return weakSelf.selectView.currentColor;
        
    } lineWidthBlock:^CGFloat{

        return weakSelf.selectView.lineWidth;
        
    } isEraserBlock:^BOOL{
        
        return weakSelf.isEraser;
        
    } drawPenTypeBlock:^DrawPenType{

        return weakSelf.selectView.penType;
    }];
    
    _drawView.backgroundColor = [UIColor whiteColor];
    
    _drawView.isDrawingBlock = ^(BOOL isDrawing) {
        
        ST(strongSelf)
        
        if (strongSelf->_selectView.alpha == 1) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                strongSelf->_selectView.alpha = !isDrawing;
            }];
            
        }else if (strongSelf->_selectView.alpha == 0){
            
            [UIView animateWithDuration:0.5 animations:^{
                
                strongSelf->_selectView.alpha = !isDrawing;
            }];
        }
    };
    
    [self addSubview:_drawView];
    
    [self addSubview:_selectView];
    
}

@end
