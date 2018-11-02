//
//  UIButton+Block.h
//  CestbonHealthCheck-Native-iOS
//
//  Created by wangyong on 2018/5/23.
//  Copyright © 2018年 wangyong. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^buttonBlock)(id sender);
@interface UIButton (Block)
+ (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title fontSize:(NSInteger)fontSize action:(dispatch_block_t)action color:(UIColor *)color;
/**
 *  带参数的block
 */
+ (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title fontSize:(NSInteger)fontSize buttonAction:(buttonBlock)buttonAction color:(UIColor *)color;
@end
@interface UIControl (block)

- (void)addBlock:(buttonBlock)block event:(UIControlEvents)event;

@end
@interface UIGestureRecognizer (block)
+ (instancetype)initWithBlockAction:(void(^)(UIGestureRecognizer * sender))blockAction;
@end
@interface NSTimer (block)
+ (instancetype)homedScheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;
@end
