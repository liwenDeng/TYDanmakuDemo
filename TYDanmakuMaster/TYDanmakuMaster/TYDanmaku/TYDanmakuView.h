//
//  TYDanmakuView.h
//  TYDanmakuMaster
//
//  Created by 邓利文 on 2016/10/12.
//  Copyright © 2016年 邓利文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TYDanmakuConfig.h"

@protocol TYDanmakuViewDelegate;

@interface TYDanmakuView : UIView

@property (nonatomic, weak) id<TYDanmakuViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame configuration:(TYDanmakuConfig *)configuration;

- (void)start;
- (void)pause;
- (void)resume;
- (void)stop;

/**
 准备数据
 */
- (void)prepareDanmakuSources:(NSArray<id<TYDanmakuModelProtocol>>*)danmakuSource;

- (void)addDanmakuSource:(id<TYDanmakuModelProtocol>)danmakuSource;

@end

#pragma mark - TYDanmakuViewDelegate
@protocol TYDanmakuViewDelegate <NSObject>

@required
// 视频播放进度，单位秒
- (CGFloat)danmakuViewGetPlayTime:(TYDanmakuView *)danmakuView;

// 视频播放缓冲状态，如果设为YES，不会绘制新弹幕，已绘制弹幕会继续动画直至消失
- (BOOL)danmakuViewIsBuffering:(TYDanmakuView *)danmakuView;

@optional
// 弹幕初始化完成
- (void)danmakuViewPerpareComplete:(TYDanmakuView *)danmakuView;

@end
