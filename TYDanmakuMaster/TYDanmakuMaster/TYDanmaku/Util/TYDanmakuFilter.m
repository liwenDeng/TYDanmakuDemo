//
//  TYDanmakuFilter.m
//  TYDanmakuMaster
//
//  Created by 邓利文 on 2016/10/12.
//  Copyright © 2016年 邓利文. All rights reserved.
//

#import "TYDanmakuFilter.h"

@implementation TYDanmakuFilter

+ (NSArray *)filterDanmakus:(NSArray *)danmakus time:(TYDanmakuTime *)time {
    if (danmakus.count < 1) {
        return nil;
    }
    
    id<TYDanmakuModelProtocol> lastDanmaku = danmakus.lastObject;
    //如果最后一个弹幕都不会显示的话，则返回Nil
    if (![self willShow:lastDanmaku curtime:time.time] ) {
        return nil;
    }
    
    id<TYDanmakuModelProtocol> firstDanmaku = danmakus.firstObject;
    //如果第一个弹幕也会显示的话，则返回全部
    if ([self willShow:firstDanmaku curtime:time.time]) {
        return danmakus;
    }
    return [self cutWithDanmakus:danmakus time:time];
}

/**
 二分法，筛选在该时间之后的弹幕
 */
+ (NSArray *)cutWithDanmakus:(NSArray *)danmakus time:(TYDanmakuTime *)time {
    NSUInteger count = danmakus.count;
    NSUInteger index, minIndex=0, maxIndex = count-1;
    id <TYDanmakuModelProtocol> danmaku = nil;
    while (maxIndex-minIndex>1) {
        index = (maxIndex+minIndex)/2;
        danmaku = danmakus[index];
        if ([self willShow:danmaku curtime:time.time]) {
            maxIndex = index;
        } else {
            minIndex = index;
        }
    }
    return [danmakus subarrayWithRange:NSMakeRange(maxIndex, count-maxIndex)];
}

/**
 判断该弹幕是否需要显示
 */
+ (BOOL)willShow:(id<TYDanmakuModelProtocol>)danmaku curtime:(CGFloat)curtime {
    return danmaku.time >= curtime;
}


/**
 判断该弹幕进入时间是否比当前时间晚上一秒
 */
+ (BOOL)isLate:(id<TYDanmakuModelProtocol>)danmaku curTime:(CGFloat)curtime {
    return danmaku.time > curtime+1;
}

@end
