//
//  DrawModel.m
//  CloudTeachers
//
//  Created by xinhao on 2018/9/29.
//  Copyright © 2018年 yubay. All rights reserved.
//

#import "DrawModel.h"
#import <objc/runtime.h>
@implementation DrawModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _penType = kDrawPenTypeCurve;
        _lineWidth = 1.0;
        _pointsArray = [[NSMutableArray alloc] init];
        _isEraser = NO;
    }
    return self;
}

@end

@implementation DrawPointModel

- (instancetype)initWithDrawModel:(DrawModel *)aModel {
    self = [super init];
    if (self) {

        _penType = aModel.penType;
        _lineWidth = aModel.lineWidth;
        _lineColor = aModel.lineColor;
        _isEraser = aModel.isEraser;
    }
    return self;
}
// 解归档
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSMutableArray * propertyArr = [NSMutableArray arrayWithArray:[DrawPointModel getPropertyList:@"DrawPointModel"]];
    
    for (NSString *property in propertyArr) {
        
        id value = [self valueForKey:property];
     
        [aCoder encodeObject:value forKey:property];
    }
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        NSMutableArray * propertyArr = [NSMutableArray arrayWithArray:[DrawPointModel getPropertyList:@"DrawPointModel"]];
        
        for (NSString *property in propertyArr) {
 
            [self setValue:[aDecoder decodeObjectForKey:property] forKey:property];
        }
    }
    return self;
}
// 实现copy 协议
- (id)copyWithZone:(NSZone *)zone {
    id copy = [[self class] allocWithZone:zone];
    NSMutableArray * propertyArr = [NSMutableArray arrayWithArray:[DrawPointModel getPropertyList:@"DrawPointModel"]];
    for (NSString *property in propertyArr) {
        id value = [self valueForKey:property];
        [copy setValue:value forKey:property];
    }
    return copy;
}
//获取类的属性列表
+ (NSMutableArray *)getPropertyList:(NSString *)tableName
{
    unsigned int count;
    Ivar * vars = class_copyIvarList(NSClassFromString(tableName), &count);
    NSMutableArray * propertyArr = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        Ivar var = vars[i];
        [propertyArr addObject:[NSString stringWithUTF8String:ivar_getName(var)]];
        
    }
    free(vars);
    return propertyArr;
}
@end
