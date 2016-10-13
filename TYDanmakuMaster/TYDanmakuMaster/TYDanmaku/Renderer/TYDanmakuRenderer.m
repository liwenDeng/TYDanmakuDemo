//
//  TYDanmakuRenderer.m
//  TYDanmakuMaster
//
//  Created by 邓利文 on 2016/10/12.
//  Copyright © 2016年 邓利文. All rights reserved.
//

#import "TYDanmakuRenderer.h"
#import "TYDanmakuTrajectory.h"
#import "TYDanmakuFilter.h"

@interface TYDanmakuRenderer ()

@property (nonatomic, weak) TYDanmakuConfig *config;
@property (nonatomic, weak) UIView *canvas;
@property (nonatomic, assign) CGFloat canvasWidth;

@property (nonatomic, strong) TYDanmakuTrajectory *danmakuLRTrajectory;   //横向弹道管理器
@property (nonatomic, strong) TYDanmakuFBTrajectory *danmakuFBTrajectory;   //底部道管理器
@property (nonatomic, strong) TYDanmakuFTTrajectory *danmakuFTTrajectory;   //顶部弹道管理器

@property (nonatomic, strong) NSMutableArray *drawArray;                //绘制的弹幕
@property (nonatomic, strong) NSMutableArray *cacheLabels;              //缓存的Label

@end

@implementation TYDanmakuRenderer

- (instancetype)initWithCanvas:(UIView *)canvas configuration:(TYDanmakuConfig *)configuration {
    if (self = [super init]) {
        _config = configuration;
        _canvasWidth = CGRectGetWidth(canvas.frame);
        _drawArray = [NSMutableArray array];
        _cacheLabels = [NSMutableArray array];
        _canvas = canvas;
        [self setCanvasFrame];
    }
    return self;
}

- (void)setCanvasFrame{
    _danmakuLRTrajectory = [[TYDanmakuTrajectory alloc] initWithConfig:_config canvaseSize:_canvas.frame.size];
    _danmakuFBTrajectory = [[TYDanmakuFBTrajectory alloc] initWithConfig:_config canvaseSize:_canvas.frame.size];
    _danmakuFTTrajectory = [[TYDanmakuFTTrajectory alloc] initWithConfig:_config canvaseSize:_canvas.frame.size];
}
#pragma mark - 屏幕旋转时 TODO
- (void)updateCanvasFrame {
    [self setCanvasFrame];
    
    [self.danmakuLRTrajectory clear];
    [self.danmakuFBTrajectory clear];
    [self.danmakuFTTrajectory clear];
}

#pragma mark - Draw
- (void)drawDanmakus:(NSArray *)danmakus time:(TYDanmakuTime *)time isBuffering:(BOOL)isBuffering {
    int LRShowCount = 0;
    //遍历已经渲染的弹幕
    for (NSInteger index=0; index<_drawArray.count;) {
        id<TYDanmakuModelProtocol>danmaku = _drawArray[index];
        //剩余时间减少
        danmaku.remainTime -= time.interval; //剩余时间-0.5秒的持续时间
        if (danmaku.remainTime<0) {
            //移除已经显示的弹幕
            [self removeDanmaku:danmaku];
            [_drawArray removeObjectAtIndex:index];
            continue;
        }
        if (danmaku.danmakuType==TYDanmakuTypeLR) {
            LRShowCount++;
        }
        [self rendererDanmaku:danmaku];
        index++;
    }
    
    //如果正在缓冲，则停止增加新的弹幕
    if (isBuffering) {
        return;
    }
    
    for (id<TYDanmakuModelProtocol> danmaku in [danmakus objectEnumerator]) {
        //如果最先的弹幕比当前视频时间晚上一秒，则停止增加新弹幕
        if ([TYDanmakuFilter isLate:danmaku curTime:time.time]) {
            break;
        }
        //如果当前屏幕上显示的弹幕超过最大值，则停止增加新弹幕
        if (_drawArray.count>=self.config.maxShowCount && !danmaku.isSelfID) {
            break;
        }
        //如果该弹幕正在显示，则跳过
        if (danmaku.isShowing) {
            continue;
        }
        //如果该弹幕进入时间晚于当前时间，跳过
        if (![TYDanmakuFilter willShow:danmaku curtime:time.time]) {
            continue;
        }
        if (danmaku.danmakuType==TYDanmakuTypeLR) {
            if (LRShowCount>self.config.maxLRShowCount && !danmaku.isSelfID) {
                continue;
            } else {
                LRShowCount++;
            }
        }
        //为弹幕分配label
        [self createLabelForDanmaku:danmaku];
        //渲染该label
        [self rendererDanmakuLabel:danmaku];
        [_drawArray addObject:danmaku];
        
        // 设置弹幕剩余时间
        danmaku.remainTime = danmaku.time-time.time+danmaku.duration;
        danmaku.trajectory = [self getHitDicForType:danmaku.danmakuType];
        
        [self rendererDanmaku:danmaku];
        if (danmaku.py>=0) {
            NSInteger zIndex = danmaku.danmakuType == TYDanmakuTypeLR ? 0 : 10;
            [self.canvas insertSubview:danmaku.label atIndex:zIndex];
            danmaku.isShowing = YES;
        }
    }
}

- (void)removeDanmaku:(id<TYDanmakuModelProtocol>)danmaku
{
    [danmaku.trajectory clearVisibleDanmaku:danmaku];
    danmaku.trajectory = nil;
    [danmaku.label removeFromSuperview];
    danmaku.isShowing = NO;
    [self removeLabelForDanmaku:danmaku];
}

- (TYDanmakuTrajectory *)getHitDicForType:(TYDanmakuType)type
{
    switch (type) {
        case TYDanmakuTypeLR:return _danmakuLRTrajectory;
        case TYDanmakuTypeFT:return _danmakuFTTrajectory;
        case TYDanmakuTypeFB:return _danmakuFBTrajectory;
    }
}

#pragma mark - Renderer
- (void)rendererDanmakuLabel:(id<TYDanmakuModelProtocol>)danmaku
{
    [danmaku rendererLabelWithConfig:self.config];
}

// 渲染弹幕
- (void)rendererDanmaku:(id<TYDanmakuModelProtocol>)danmaku
{
    [danmaku layoutWithScreenWidth:_canvasWidth];
    if (!danmaku.isShowing) {   //碰撞检测
        float py = [danmaku.trajectory layoutPyForDanmaku:danmaku];
        if (py<0) {
            if (danmaku.isSelfID) {
                py = danmaku.danmakuType!=TYDanmakuTypeFB?0:(CGRectGetHeight(self.canvas.frame)-self.config.trajectoryHeight);
            } else {
                danmaku.remainTime = -1;
            }
        }
        danmaku.py = py;
    } else if (danmaku.danmakuType!=TYDanmakuTypeLR) {
        return;
    }
    if (danmaku.isShowing) {
        if ([danmaku.text isEqualToString:@"🍎This is Test Danmaku!🍎"]) {
            NSLog(@"测试弹幕动画！");
        }
        [UIView animateWithDuration:danmaku.remainTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            danmaku.label.frame = CGRectMake(-danmaku.size.width, danmaku.py, danmaku.size.width, danmaku.size.height);
        } completion:nil];
    } else {
        danmaku.label.frame = CGRectMake(danmaku.px, danmaku.py, danmaku.size.width, danmaku.size.height);
    }
}

#pragma mark - label
- (void)removeLabelForDanmaku:(id<TYDanmakuModelProtocol>)danmaku
{
    UILabel *cacheLabel = danmaku.label;
    if (cacheLabel) {
        [cacheLabel.layer removeAllAnimations];
        [_cacheLabels addObject:cacheLabel];
        danmaku.label = nil;
    }
}

- (void)createLabelForDanmaku:(id<TYDanmakuModelProtocol>)danmaku
{
    if (danmaku.label) {
        return;
    }
    if (_cacheLabels.count<1) {
        danmaku.label = [[TYBaseDanmakuLabel alloc] init];
    } else {
        danmaku.label = [_cacheLabels lastObject];
        [_cacheLabels removeLastObject];
    }
}

#pragma mark - 
- (void)pauseRenderer
{
    for (id<TYDanmakuModelProtocol> danmaku in _drawArray.objectEnumerator) {
        if (danmaku.danmakuType!=TYDanmakuTypeLR) {
            continue;
        }
        CALayer *layer = danmaku.label.layer;
        CGRect rect = danmaku.label.frame;
        if (layer.presentationLayer) {
            rect = ((CALayer *)layer.presentationLayer).frame;
            rect.origin.x-=1;
        }
        danmaku.label.frame = rect;
        [danmaku.label.layer removeAllAnimations];
    }
}

- (void)stopRenderer
{
    for (id<TYDanmakuModelProtocol> danmaku in _drawArray.objectEnumerator) {
        [danmaku.label removeFromSuperview];
        [self removeLabelForDanmaku:danmaku];
        danmaku.remainTime = -1;
        danmaku.isShowing = NO;
        danmaku.trajectory = nil;
    }
    [_drawArray removeAllObjects];
    [self.danmakuLRTrajectory clear];
    [self.danmakuFTTrajectory clear];
    [self.danmakuFBTrajectory clear];
}

@end
