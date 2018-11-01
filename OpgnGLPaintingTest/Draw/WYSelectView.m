//
//  WYSelectView.m
//  WYPhotoEditor
//
//  Created by 王勇 on 2018/6/25.
//  Copyright © 2018年 王勇. All rights reserved.
//

#import "WYSelectView.h"
#import "WYColorSlider.h"
#import "WYMain.h"
@interface WYSelectView ()

@end
@implementation WYSelectView
{
    WYColorSlider * _colorSlider;
    
    UISlider * _widthSlider;
    
    UIView * _topSelectView;
    
    UIView * _selectView;
    
    NSArray * _defaultColorArray;
    
    NSInteger _selectColorIndex;
    
    UIView * _selectTypeView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self setUpViews];
        
    }
    return self;
}

- (void)setUpTopSelectView
{
    
    [_topSelectView removeFromSuperview];
    
    _topSelectView = nil;
    
    NSArray * defaultColorArray = @[[UIColor whiteColor],[UIColor blackColor],[UIColor redColor],[UIColor yellowColor],[UIColor greenColor],[UIColor blueColor],[UIColor colorWithHue:0.8 saturation:1 brightness:1 alpha:1]];
    
    NSArray * penTypeArray = @[@"曲线",@"直线",@"矩形",@"圆形"];
    
    NSArray * imgNameArray = @[@"wy_colorSelect",penTypeArray[self.penType]];
    
    NSArray * imgSelectedNameArray = @[@"wy_colorSelect",@""];
    
    UIWindow* desWindow = [UIApplication sharedApplication].delegate.window;
    
    NSInteger buttonCount = defaultColorArray.count + imgNameArray.count;
    
    CGFloat space = self.Width/10;
    
    CGFloat buttonWidth = space*0.4;
    
    CGFloat selectButtonWidth = space*0.6;
    
    CGFloat selectTypeButtonHeight = 25;
    
    CGFloat selectTypeButtonWidth = 60;
    
    _topSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.Width, space + 20)];
    
    if (_selectColorIndex < defaultColorArray.count)  self.currentColor = defaultColorArray[_selectColorIndex];
    
    WS(weakSelf)
    
    for (NSInteger i = 0; i < buttonCount; i++) {
        
        UIButton * button = [UIButton initWithFrame:CGRectMake(i*space + space/2 - buttonWidth/2, space/2 - buttonWidth/2 + 20, buttonWidth, buttonWidth) title:nil fontSize:16 buttonAction:^(UIButton * sender) {
            
            ST(strongSelf)

            if (i < defaultColorArray.count) {
                
                strongSelf -> _selectColorIndex = i;
                
                strongSelf -> _colorSlider = nil;
                
                [weakSelf setUpTopSelectView];
                
                weakSelf.currentColor = defaultColorArray[i];
                
            }else if (i == defaultColorArray.count){

                [weakSelf setUpColorSlider];
                
            }else if (i == buttonCount - 1){
                
                CGRect frame = [sender convertRect:sender.bounds toView:desWindow];
                
                NSInteger buttonCount = penTypeArray.count;
                
                UIView * selectBackView = [[UIView alloc] initWithFrame:desWindow.bounds];
                
                selectBackView.backgroundColor = nil;
                
                UITapGestureRecognizer * tap = [UITapGestureRecognizer initWithBlockAction:^(UIGestureRecognizer *sender) {
                    
                    [selectBackView removeFromSuperview];
                }];
                
                [selectBackView addGestureRecognizer:tap];
                
                UIView * selectView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y - buttonCount*selectTypeButtonHeight, selectTypeButtonWidth, selectTypeButtonHeight*buttonCount)];
                
                selectView.layer.borderColor = UIColorFromRGB(0xffffff).CGColor;
                
                selectView.layer.borderWidth = 0.5;
                
                for (NSInteger j = 0; j < buttonCount; j++) {
                    
                    UIButton * selectButton = [UIButton initWithFrame:CGRectMake(0, j*selectTypeButtonHeight, selectTypeButtonWidth, selectTypeButtonHeight) title:penTypeArray[j] fontSize:14 buttonAction:^(UIButton * sender2) {

                        [sender setTitle:sender2.currentTitle forState:UIControlStateNormal];
                        
                        weakSelf.penType = j;
                        
                        [selectBackView removeFromSuperview];
                        
                    } color:UIColorFromRGB(0x333333)];
                    
                    if (j < buttonCount - 1) {
                        
                        UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, selectTypeButtonHeight - 1, selectTypeButtonWidth, 1)];
                        
                        lineView.backgroundColor = [UIColor redColor];
                        
                        [selectButton addSubview:lineView];
                    }
  
                    [selectView addSubview:selectButton];
                }
                
                selectView.layer.borderWidth = 1;
                
                selectView.layer.borderColor = [UIColor redColor].CGColor;
                
                [selectBackView addSubview:selectView];
                
                strongSelf->_selectTypeView = selectBackView;
                
                [desWindow addSubview:selectBackView];
            }
            
        } color:nil];

        if (i < defaultColorArray.count) {
            
            [button setBackgroundColor:defaultColorArray[i]];
            
            button.layer.cornerRadius = buttonWidth/2;
            
            button.layer.borderColor = UIColorFromRGB(0xffffff).CGColor;
            
            button.layer.borderWidth = 1;
            
            button.layer.borderWidth = 2;
            
        }else{
            
            UIImage * image = [UIImage imageNamed:imgNameArray[i - defaultColorArray.count]];
            
            if (image != nil) {
                
                UIImage * selectImage = [UIImage imageNamed:imgSelectedNameArray[i - defaultColorArray.count]];
                
                [button setImage:image forState:UIControlStateNormal];
                
                [button setImage:selectImage forState:UIControlStateSelected];
                
                button.selected = YES;
                
            }else{
                
                [button setTitle:imgNameArray[i - defaultColorArray.count] forState:UIControlStateNormal];
                
                [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                
                button.layer.borderColor = UIColorFromRGB(0x999999).CGColor;
                
                button.layer.borderWidth = 1;
                
                button.layer.cornerRadius = 5;
                
                button.Width = selectTypeButtonWidth;
                
                button.Height = selectTypeButtonHeight;
                
                button.Y -= 5;
            }
        }
        
        if (i == _selectColorIndex && i < defaultColorArray.count + 1) {
            
            button.frame = CGRectMake(i*space + space/2 - selectButtonWidth/2, space/2 - selectButtonWidth/2 + 20, selectButtonWidth, selectButtonWidth);
            
            button.layer.cornerRadius = selectButtonWidth/2;
            
        }
        
        button.tag = 1000 + i;
        
        [_topSelectView addSubview:button];
    }
    
    _defaultColorArray = defaultColorArray;
    
    [_selectView addSubview:_topSelectView];
}

- (void)setUpColorSlider
{
    
    UIView * slideView = [[UIView alloc] initWithFrame:self.bounds];
    
    slideView.backgroundColor = self.backgroundColor;
    
    _selectView.hidden = YES;
    
    WS(weakSelf)
    
    UIButton * backButton = [UIButton initWithFrame:CGRectMake(15, 15, 20, 20) title:nil fontSize:0 action:^{
        
        ST(strongSelf)
        
        [slideView removeFromSuperview];
        
        strongSelf->_selectView.hidden = NO;
        
        [strongSelf setUpTopSelectView];

    } color:nil];
    
    [backButton setImage:[UIImage imageNamed:@"wy_back"] forState:UIControlStateNormal];
    
    UIColor * tempColor = self.currentColor;
    
    _colorSlider = [[WYColorSlider alloc] initWithFrame:CGRectMake(0, self.Height/2 - 17, self.Width, 34) color:nil];
    
    _colorSlider.currentColor = tempColor;
    
    _selectColorIndex = _defaultColorArray.count;
    
    [slideView addSubview:_colorSlider];
                             
    [slideView addSubview:backButton];
    
    [self addSubview:slideView];
}
- (void)setUpWidthSlider
{

    _widthSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, self.Height/2 + self.Height/4 - 17, self.Width, 34)];
    
    _widthSlider.backgroundColor = [UIColor colorWithPatternImage:[self widthSliderBackground]];
    
    [_widthSlider setMaximumTrackImage:[UIImage new] forState:UIControlStateNormal];
    
    [_widthSlider setMinimumTrackImage:[UIImage new] forState:UIControlStateNormal];
    
    _widthSlider.value = 0.1;
    
    _widthSlider.thumbTintColor = UIColorFromRGB(0xffffff);
    
    [_selectView addSubview:_widthSlider];
}
- (void)setUpViews
{
    _selectColorIndex = 2;
 
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    
    gradientLayer.borderWidth = 0;
    
    gradientLayer.frame = self.bounds;
    
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[
                             UIColorFromRGB(0xffffff) CGColor],
                            (id)[[UIColorFromRGB(0x000000) colorWithAlphaComponent:0.01] CGColor],
                            nil];
    
    [self.layer insertSublayer:gradientLayer atIndex:0];
    
    self.layer.masksToBounds = YES;
    
    _selectView = [[UIView alloc] initWithFrame:self.bounds];
    
    [self addSubview:_selectView];
    
    [self setUpTopSelectView];
    
    [self setUpWidthSlider];
    
}
- (UIImage*)widthSliderBackground
{
    CGSize size = _widthSlider.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *color = [UIColorFromRGB(0x000000) colorWithAlphaComponent:0.5];
    
    CGFloat strRadius = 1;
    
    CGFloat endRadius = size.height/2 * 0.6;
    
    CGPoint strPoint = CGPointMake(strRadius + 5, size.height/2 - 2);
    
    CGPoint endPoint = CGPointMake(size.width-endRadius - 1, strPoint.y);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddArc(path, NULL, strPoint.x, strPoint.y, strRadius, -M_PI/2, M_PI-M_PI/2, YES);
    
    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y + endRadius);
    
    CGPathAddArc(path, NULL, endPoint.x, endPoint.y, endRadius, M_PI/2, M_PI+M_PI/2, YES);
    
    CGPathAddLineToPoint(path, NULL, strPoint.x, strPoint.y - strRadius);
    
    CGPathCloseSubpath(path);
    
    CGContextAddPath(context, path);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGContextFillPath(context);
    
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    
    CGPathRelease(path);
    
    UIGraphicsEndImageContext();
    
    return tmp;
}
- (UIColor *)currentColor
{
    return _colorSlider ? _colorSlider.currentColor : _currentColor;
}
- (CGFloat)lineWidth
{
    return 1 + _widthSlider.value*10;
}
@end
