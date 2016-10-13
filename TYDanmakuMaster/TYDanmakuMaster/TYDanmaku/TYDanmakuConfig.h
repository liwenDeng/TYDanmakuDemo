//
//  TYDanmakuConfig.h
//  TYDanmakuMaster
//
//  Created by 邓利文 on 2016/10/12.
//  Copyright © 2016年 邓利文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TYDanmakuTrajectory.h"
#import "TYBaseDanmakuLabel.h"

/**
 弹幕类型

 - TYDanmakuTypeLR:      从右到左
 - TYDanmakuTypeFT:      顶部
 - TYDanmakuTypeFB:      底部
 - TYDanmakuTypeUnknown: 未知
 */
typedef NS_ENUM (NSUInteger, TYDanmakuType) {
    TYDanmakuTypeLR = 0,
    TYDanmakuTypeFT = 1,
    TYDanmakuTypeFB = 2,
};

/**
 配置选项
 */
@interface TYDanmakuConfig : NSObject

@property (nonatomic, assign) CGFloat duration; //每条弹幕持续时间
@property (nonatomic, assign) CGFloat trajectoryHeight; //每条弹幕占的高度
@property (nonatomic, assign) CGFloat fontSize; //字体大小
@property (nonatomic, assign) CGFloat maxLRShowCount;   //同时最多显示条数 从右到左方向
@property (nonatomic, assign) CGFloat maxShowCount; //最大显示数

@property (nonatomic, assign) BOOL enableOverlap;   //是否允许弹幕重叠
@property (nonatomic, assign) BOOL showLineWhenSelf;    //当弹幕是自己发送时是否显示下划线

@end

#pragma mark - TYDanmakuModelProtocol
/**
 Model 需要遵守的协议
 */
@protocol TYDanmakuModelProtocol <NSObject>

@property (nonatomic, assign) TYDanmakuType danmakuType;

@property (nonatomic, assign) CGFloat time;       //弹幕进入时间
@property (nonatomic, assign) CGFloat duration;   //持续时间
@property (nonatomic, assign) CGFloat remainTime; //剩余时间

//label property
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor  *textColor;
@property (nonatomic, assign) CGFloat   textSize;

//label frame
@property (nonatomic, assign) CGFloat  px;
@property (nonatomic, assign) CGFloat  py;
@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) BOOL   isMeasured;    //标记已经计算过frame
@property (nonatomic, assign) BOOL   isShowing;     //是否正在显示

@property (nonatomic, strong) TYBaseDanmakuLabel *label;
@property (nonatomic, weak) TYDanmakuTrajectory *trajectory;    //弹道控制器

@property (nonatomic, assign) BOOL isSelfID;        //是否是自己发送的弹幕

/**
 为label赋初始值
 可以在这里进行样式自定义
 */
- (void)rendererLabelWithConfig:(TYDanmakuConfig *)config;

/**
 初始化时弹幕宽度
 如果需要增加左右边距，可以在这里实现
 */
- (void)measureSizeWithPaintHeight:(CGFloat)paintHeight;

/**
 计算弹幕进入时初始位置X坐标
 */
- (void)layoutWithScreenWidth:(CGFloat)width;

/**
 在某时间点下计算的X坐标
 @param width      屏幕宽度
 @param remainTime 剩余时间
 @return 原点X值
 */
- (CGFloat)pxWithScreenWidth:(CGFloat)width remainTime:(CGFloat)remainTime;

@end
