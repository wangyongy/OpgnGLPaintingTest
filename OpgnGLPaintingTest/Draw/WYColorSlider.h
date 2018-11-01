//
//  WYColorSlider.h
//  WYPhotoEditor
//
//  Created by 王勇 on 2018/6/25.
//  Copyright © 2018年 王勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYColorSlider : UISlider

@property (nonatomic, strong)UIColor * currentColor;                //当前颜色

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color;

@end
