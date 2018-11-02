//
//  UIAlertController+WY.m
//  WYDrawingBoard
//
//  Created by 王勇 on 2018/7/2.
//  Copyright © 2018年 王勇. All rights reserved.
//

#import "UIAlertController+WY.h"

@implementation UIAlertController (WY)
+ (UIAlertController *)showWithTitle:(NSString *)title message:(NSString *)messsage cancelTitle:(NSString *)cancelTitle  cancelHandler:(void(^)(void))cancelmHandler confirmTitle:(NSString *)confirmTitle confirmHandler:(void(^)(void))confirmHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:messsage preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelTitle) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (cancelmHandler) cancelmHandler();
        }];
        [alertController addAction:cancelAction];
    }
    
    if (confirmTitle) {
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (confirmHandler) confirmHandler();
        }];
        [alertController addAction:confirmAction];
    }
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    return alertController;
}
@end
