//
//  WYDrawingBoardView.h
//  WYDrawingBoard
//
//  Created by 王勇 on 2018/7/2.
//  Copyright © 2018年 王勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYDrawingBoardView : UIView

@property (nonatomic, assign) BOOL isEraser;

/**  清除所有线段,并移除所有的point  */
- (void)clearLines;

/**  撤销上一步操作  */
- (void)undo;

@end
