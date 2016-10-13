//
//  TYBaseDanmukuModel.h
//  TYDanmakuMaster
//
//  Created by 邓利文 on 2016/10/12.
//  Copyright © 2016年 邓利文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYDanmakuConfig.h"

@interface TYDanmakuBaseModel : NSObject <TYDanmakuModelProtocol>

@property (nonatomic, assign) TYDanmakuType danmakuType;

@property (nonatomic, assign) CGFloat time;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat remainTime;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor  *textColor;
@property (nonatomic, assign) CGFloat     textSize;

@property (nonatomic, assign) CGFloat  px;
@property (nonatomic, assign) CGFloat  py;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) BOOL   isMeasured;

@property (nonatomic, assign) BOOL   isShowing;
@property (nonatomic, strong) TYBaseDanmakuLabel *label;
@property (nonatomic, weak) TYDanmakuTrajectory *trajectory;    //弹道控制器

@property (nonatomic, assign) BOOL isSelfID;    //是否是自己发送的弹幕

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


@interface TYDanmakuLRModel : TYDanmakuBaseModel

@end

@interface TYDanmakuFTModel : TYDanmakuBaseModel

@end

@interface TYDanmakuFBModel : TYDanmakuBaseModel

@end
