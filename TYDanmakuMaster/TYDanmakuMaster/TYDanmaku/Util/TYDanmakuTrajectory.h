//
//  TYDanmakuTrajectory.h
//  TYDanmakuMaster
//
//  Created by 邓利文 on 2016/10/12.
//  Copyright © 2016年 邓利文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TYDanmakuConfig;
@protocol TYDanmakuModelProtocol;

/**
 弹幕所在弹道控制器
 */
@interface TYDanmakuTrajectory : NSObject

/**
 初始化弹道管理器

 @param config     配置选项
 @param canvasSize 画布大小

 @return <#return value description#>
 */
- (instancetype)initWithConfig:(TYDanmakuConfig*)config canvaseSize:(CGSize)canvasSize;


/**
 在弹道中字典中去掉该弹道，使该弹道可用
 */
- (void)clearVisibleDanmaku:(id<TYDanmakuModelProtocol>)danmaku;


/**
 获取该弹幕所在弹道的Y值
 */
- (CGFloat)layoutPyForDanmaku:(id<TYDanmakuModelProtocol>)danmaku;


/**
 清除所有弹道
 */
- (void)clear;

@end

@interface TYDanmakuFTTrajectory : TYDanmakuTrajectory

@end

@interface TYDanmakuFBTrajectory : TYDanmakuTrajectory

@end
