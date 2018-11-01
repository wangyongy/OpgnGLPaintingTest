//
//  ViewController.m
//  OpgnGLPaintingTest
//
//  Created by 王勇 on 2018/10/25.
//  Copyright © 2018年 王勇. All rights reserved.
//

#import "ViewController.h"
#import "WYDrawingBoardView.h"
@interface ViewController ()
{
    WYDrawingBoardView * _drawingBoardView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"eraser" style:UIBarButtonItemStyleDone target:self action:@selector(eraserButtonAction:)]];

    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"clear" style:UIBarButtonItemStyleDone target:self action:@selector(clearButtonAction:)],[[UIBarButtonItem alloc] initWithTitle:@"undo" style:UIBarButtonItemStyleDone target:self action:@selector(undoButtonAction:)]];

    // Add the control to the window
    _drawingBoardView = [[WYDrawingBoardView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_drawingBoardView];

    // Do any additional setup after loading the view, typically from a nib.
}
#pragma mark - action
- (IBAction)clearButtonAction:(UIButton *)sender
{
    [_drawingBoardView clearLines];
}
- (IBAction)eraserButtonAction:(UIButton *)sender
{
    _drawingBoardView.isEraser = !_drawingBoardView.isEraser;
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:_drawingBoardView.isEraser ? @"draw" : @"eraser" style:UIBarButtonItemStyleDone target:self action:@selector(eraserButtonAction:)]];
}
- (IBAction)undoButtonAction:(UIButton *)sender
{
    [_drawingBoardView undo];
}
@end

