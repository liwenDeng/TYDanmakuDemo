//
//  TYDanmakuFilter.h
//  TYDanmakuMaster
//
//  Created by 邓利文 on 2016/10/12.
//  Copyright © 2016年 邓利文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TYDanmakuTime.h"
#import "TYDanmakuConfig.h"

/**
 弹幕过滤器 - 根据播放时间从弹幕池中筛选
 */
@interface TYDanmakuFilter : NSObject

+ (NSArray *)filterDanmakus:(NSArray *)danmakus time:(TYDanmakuTime *)time;

+ (BOOL)willShow:(id<TYDanmakuModelProtocol>)danmaku curtime:(CGFloat)curtime;

+ (BOOL)isLate:(id<TYDanmakuModelProtocol>)danmaku curTime:(CGFloat)curtime;

@end
