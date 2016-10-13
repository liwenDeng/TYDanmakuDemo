//
//  TYDanmakuTrajectory.m
//  TYDanmakuMaster
//
//  Created by 邓利文 on 2016/10/12.
//  Copyright © 2016年 邓利文. All rights reserved.
//

#import "TYDanmakuTrajectory.h"
#import "TYDanmakuConfig.h"

@interface TYDanmakuTrajectory ()

@property (nonatomic, weak) TYDanmakuConfig* config;
@property (nonatomic, assign) CGSize canvasSize;
@property (nonatomic, strong) NSMutableDictionary *hitDanmakus;    //记录弹道的字典
@property (nonatomic, assign) NSInteger maxPyIndex;     //记录所在弹道最大行数下标

@end

@implementation TYDanmakuTrajectory

- (instancetype)initWithConfig:(TYDanmakuConfig *)config canvaseSize:(CGSize)canvasSize {
    if (self = [super init]) {
        _config = config;
        _hitDanmakus = [NSMutableDictionary dictionary];
        [self setupCanvasSize:canvasSize];
    }
    return self;
}

#pragma mark - for override 

/**
 如果需要自定义弹幕弹道，在子类中重写以下方法

 @param canvasSize <#canvasSize description#>
 */
- (void)setupCanvasSize:(CGSize)canvasSize {
    _canvasSize = canvasSize;
    _maxPyIndex = canvasSize.height / _config.trajectoryHeight;
}

- (void)clearVisibleDanmaku:(id<TYDanmakuModelProtocol>)danmaku {
    NSInteger pyIndex = danmaku.py/self.config.trajectoryHeight;
    id key = @(pyIndex);
    id<TYDanmakuModelProtocol> hitDanmaku = self.hitDanmakus[key];
    if (hitDanmaku==danmaku) {
        [self.hitDanmakus removeObjectForKey:key];
    }
}

- (CGFloat)layoutPyForDanmaku:(id<TYDanmakuModelProtocol>)danmaku {
    CGFloat py = -self.config.trajectoryHeight;
    id<TYDanmakuModelProtocol> tempDanmaku = nil;
    
    BOOL alwasOverlap = YES; //标记是否会重叠
    
    for (NSInteger index = 0; index<_maxPyIndex; index++) {
        tempDanmaku = self.hitDanmakus[@(index)];
        if (!tempDanmaku) {
            self.hitDanmakus[@(index)] = danmaku;
            py = [self getpyDicForType:danmaku.danmakuType Index:index];
            alwasOverlap = NO;
            break;
        }
        if (![self checkIsWillHitWithWidth:_canvasSize.width DanmakuL:tempDanmaku DanmakuR:danmaku]) {
            self.hitDanmakus[@(index)] = danmaku;
            py = [self getpyDicForType:danmaku.danmakuType Index:index];
            alwasOverlap = NO;
            break;
        }
    }
    
    //如果始终会重叠，并且允许重叠，则返回一个弹道的y值
    if (alwasOverlap && self.config.enableOverlap) {
        NSInteger index = arc4random() % self.maxPyIndex;
        self.hitDanmakus[@(index)] = danmaku;
        py = [self getpyDicForType:danmaku.danmakuType Index:index];
    }
    
    return py;
}

- (CGFloat )getpyDicForType:(TYDanmakuType)type Index:(NSInteger)index
{
    return index * self.config.trajectoryHeight;
}

- (BOOL)checkIsWillHitWithWidth:(CGFloat)width DanmakuL:(id<TYDanmakuModelProtocol>)danmakuL DanmakuR:(id<TYDanmakuModelProtocol>)danmakuR
{
    if (danmakuL.remainTime<=0) {
        return NO;
    }
    if (danmakuL.px+danmakuL.size.width>danmakuR.px) {
        return YES;
    }
    float minRemainTime = MIN(danmakuL.remainTime, danmakuR.remainTime);
    float px1 = [danmakuL pxWithScreenWidth:width remainTime:(danmakuL.remainTime-minRemainTime)];
    float px2 = [danmakuR pxWithScreenWidth:width remainTime:(danmakuR.remainTime-minRemainTime)];
    if (px1+danmakuL.size.width>px2) {
        return YES;
    }
    return NO;
}

- (void)clear {
    [_hitDanmakus removeAllObjects];
}

@end

#pragma mark - TYDanmakuFTTrajectory
@implementation TYDanmakuFTTrajectory

- (void)setCanvasSize:(CGSize)canvasSize
{
    [super setCanvasSize:canvasSize];
    self.maxPyIndex /=2;
}

- (BOOL)checkIsWillHitWithWidth:(float)width DanmakuL:(id<TYDanmakuModelProtocol>)danmakuL DanmakuR:(id<TYDanmakuModelProtocol>)danmakuR
{
    if (danmakuL.remainTime<=0) {
        return NO;
    }
    return YES;
}

@end

#pragma mark - TYDanmakuFBTrajectory
@implementation TYDanmakuFBTrajectory

- (CGFloat )getpyDicForType:(TYDanmakuType)type Index:(NSInteger)index
{
    return self.canvasSize.height-self.config.trajectoryHeight*(index+1);
}

@end
