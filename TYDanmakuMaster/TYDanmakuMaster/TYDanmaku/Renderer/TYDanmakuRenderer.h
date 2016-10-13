//
//  TYDanmakuRenderer.h
//  TYDanmakuMaster
//
//  Created by 邓利文 on 2016/10/12.
//  Copyright © 2016年 邓利文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYDanmakuConfig.h"
#import "TYDanmakuTime.h"

/**
 弹幕渲染器
 */
@interface TYDanmakuRenderer : NSObject

- (instancetype)initWithCanvas:(UIView *)canvas configuration:(TYDanmakuConfig *)configuration;

- (void)drawDanmakus:(NSArray *)danmakus time:(TYDanmakuTime *)time isBuffering:(BOOL)isBuffering;

- (void)pauseRenderer;
- (void)stopRenderer;

@end
