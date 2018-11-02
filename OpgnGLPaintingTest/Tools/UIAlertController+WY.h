//
//  UIAlertController+WY.h
//  WYDrawingBoard
//
//  Created by 王勇 on 2018/7/2.
//  Copyright © 2018年 王勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (WY)

+ (UIAlertController *)showWithTitle:(NSString *)title message:(NSString *)messsage cancelTitle:(NSString *)cancelTitle  cancelHandler:(void(^)(void))cancelmHandler confirmTitle:(NSString *)confirmTitle confirmHandler:(void(^)(void))confirmHandler;

@end
