//
//  WYSelectView.h
//  WYPhotoEditor
//
//  Created by 王勇 on 2018/6/25.
//  Copyright © 2018年 王勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYSelectView : UIView

@property (nonatomic, strong) UIColor * currentColor;

@property (nonatomic, assign) CGFloat lineWidth;

@property(nonatomic,assign) NSInteger penType;

@property (nonatomic, copy) void (^revokeBlock)(void);                          //点击撤销后的回调

@end
