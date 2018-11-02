//
//  WYMain.h
//  WYPhotoEditor
//
//  Created by 王勇 on 2018/6/25.
//  Copyright © 2018年 王勇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+Frame.h"
#import "UIButton+Block.h"
#import "UIColor+WY.h"
#import "UIAlertController+WY.h"
@interface WYMain : NSObject

#define WYScreenWidth     [[UIScreen mainScreen] bounds].size.width   //屏幕宽度

#define WYScreenHeight    [[UIScreen mainScreen] bounds].size.height  //屏幕高度

#define UIColorFromRGB(rgbValue)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0] //rgb颜色

#define WS(weakSelf)            __weak __typeof(&*self)weakSelf = self; // 弱引用

#define ST(strongSelf)          __strong __typeof(&*self)strongSelf = weakSelf;

@end
