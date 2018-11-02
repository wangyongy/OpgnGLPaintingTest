//
//  UIButton+Block.m
//  CestbonHealthCheck-Native-iOS
//
//  Created by wangyong on 2018/5/23.
//  Copyright © 2018年 wangyong. All rights reserved.
//

#import "UIButton+Block.h"
#import <objc/runtime.h>
@implementation UIControl (block)
static char blockKey;
- (void)addBlock:(buttonBlock)block event:(UIControlEvents)event
{
    objc_setAssociatedObject(self, &blockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callControlActionBlock:) forControlEvents:event];
}
- (void)callControlActionBlock:(id)sender {
    buttonBlock block = (buttonBlock)objc_getAssociatedObject(self, &blockKey);
    if (block) {
        block(sender);
    }
}
@end
@implementation UIGestureRecognizer (block)
static char blockKey;
+ (instancetype)initWithBlockAction:(void(^)(UIGestureRecognizer * sender))blockAction
{
    UIGestureRecognizer * gestureRecognizer = [[[self class] alloc] init];
    [gestureRecognizer addBlock:blockAction];
    return gestureRecognizer;
}
- (void)addBlock:(void(^)(UIGestureRecognizer * sender))block
{
    objc_setAssociatedObject(self, &blockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(gestureRecognizerAction:)];
}
- (void)gestureRecognizerAction:(UIGestureRecognizer *)sender
{
    buttonBlock block = (buttonBlock)objc_getAssociatedObject(self, &blockKey);
    if (block) {
        block(sender);
    }
}
@end
@implementation NSTimer (block)
static char blockKey;
+ (instancetype)homedScheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block
{
    /**
     *  带block的定时器要求ios10
     */
    if (@available(iOS 10.0, *)) {
        
        return [NSTimer scheduledTimerWithTimeInterval:interval repeats:repeats block:block];
    }
    
    objc_setAssociatedObject(self, &blockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(timerAction:) userInfo:nil repeats:repeats];
}
+ (void)timerAction:(NSTimer *)timer
{
    void (^block)(NSTimer *timer)  = (void (^)(NSTimer *timer))objc_getAssociatedObject(self, &blockKey);
    if (block) {
        block(timer);
    }
}
@end
@implementation UIButton (block)
static char blockKey;
+ (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title fontSize:(NSInteger)fontSize action:(dispatch_block_t)action color:(UIColor *)color
{
    UIButton * btn = [[UIButton alloc] initWithFrame:frame];
    btn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:color forState:UIControlStateNormal];
    if (action) {
        [btn addBlock:action];
    }
    return btn;
}

- (void)addBlock:(dispatch_block_t)block
{
    objc_setAssociatedObject(self, &blockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)callActionBlock:(id)sender {
    dispatch_block_t block = (dispatch_block_t)objc_getAssociatedObject(self, &blockKey);
    if (block) {
        block();
    }
}
/**
 *  带参block
 */
+ (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title fontSize:(NSInteger)fontSize buttonAction:(buttonBlock)buttonAction color:(UIColor *)color
{
    UIButton * btn = [[UIButton alloc] initWithFrame:frame];
    btn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:color forState:UIControlStateNormal];
    if (buttonAction) {
        [btn addButtonBlock:buttonAction];
    }
    return btn;
}
- (void)addButtonBlock:(buttonBlock)block
{
    objc_setAssociatedObject(self, &blockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callButtonActionBlock:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)callButtonActionBlock:(id)sender {
    buttonBlock block = (buttonBlock)objc_getAssociatedObject(self, &blockKey);
    if (block) {
        block(sender);
    }
}
@end
