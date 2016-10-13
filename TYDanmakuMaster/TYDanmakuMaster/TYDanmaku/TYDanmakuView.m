
//
//  TYDanmakuView.m
//  TYDanmakuMaster
//
//  Created by 邓利文 on 2016/10/12.
//  Copyright © 2016年 邓利文. All rights reserved.
//

#import "TYDanmakuView.h"
#import "TYDanmakuTime.h"
#import "TYDanmakuRenderer.h"
#import "TYDanmakuFilter.h"

//延迟区间，当延迟超过5.0s 则会重新从弹幕池中取需要加载的弹幕
static const CGFloat kDanmakuFilterInterval = 5.0f;

//每0.5秒去从弹幕池中取需要加载的弹幕
static const CGFloat kFrameInterval = 0.5f;

@interface TYDanmakuView ()

@property (nonatomic, strong) NSTimer *timer;   //计时器
@property (nonatomic, assign) CGFloat timeCount;
@property (nonatomic, strong) TYDanmakuTime *danmakuTime;//记录当前弹幕时间轴
@property (nonatomic, strong) TYDanmakuConfig *config;

@property (nonatomic, assign) BOOL isPrepared;  //数据准备状态
@property (nonatomic, assign) BOOL isPlaying;   //弹幕播放状态
@property (nonatomic, assign) BOOL isPreFilter; //弹幕是否已经过滤

@property (nonatomic, strong) NSArray  *danmakus;   //所有弹幕
@property (nonatomic, strong) NSArray  *curDanmakus;//过滤后需要加载的弹幕

@property (nonatomic, strong) TYDanmakuRenderer *danmakuRenderer;   //渲染器

@end

@implementation TYDanmakuView

- (void)dealloc {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(TYDanmakuConfig *)configuration;
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.clipsToBounds = YES;
        self.config = configuration;

        _danmakuTime = [[TYDanmakuTime alloc] init];
        _danmakuRenderer = [[TYDanmakuRenderer alloc] initWithCanvas:self configuration:configuration];
        
    }
    return self;
}

- (void)prepareDanmakuSources:(NSArray<id<TYDanmakuModelProtocol>> *)danmakuSource {
    
    self.isPrepared = NO;
    self.danmakus = nil;
    self.curDanmakus = nil;
    
    NSMutableArray *danmakus = [NSMutableArray arrayWithArray:danmakuSource];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //model
        //按照时间升序
        [danmakus sortUsingComparator:^NSComparisonResult(id<TYDanmakuModelProtocol> obj1, id<TYDanmakuModelProtocol> obj2) {
            return obj1.time < obj2.time ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.danmakus = danmakus;
            self.isPrepared = YES;
            self.isPreFilter = YES;
            if ([self.delegate respondsToSelector:@selector(danmakuViewPerpareComplete:)]) {
                [self.delegate danmakuViewPerpareComplete:self];
            }
        });
    });
}

- (void)start
{
    if (!self.delegate) {
        return;
    }
    [self resume];
}

- (void)resume
{
    if (self.isPlaying || !self.isPrepared) {
        return;
    }
    self.isPlaying = YES;
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:kFrameInterval target:self selector:@selector(onTimeCount) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        [_timer fire];
    }
}

- (void)pause
{
    BOOL isBuffering = [self.delegate danmakuViewIsBuffering:self];
    if (!self.isPlaying || isBuffering) {
        return;
    }
    self.isPlaying = NO;
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    [self.danmakuRenderer pauseRenderer];
}

- (void)stop
{
    self.isPlaying = NO;
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [self.danmakuRenderer stopRenderer];
}


#pragma mark - Draw
- (void)onTimeCount
{
    CGFloat playTime = [self.delegate danmakuViewGetPlayTime:self];
    if (playTime<=0) {
        return;
    }
    
    //计算播放时间与弹幕当前时间差值
    float interval = playTime-_danmakuTime.time;
    
    _danmakuTime.time = playTime;   //弹幕播放时间
    _danmakuTime.interval = kFrameInterval; //弹幕持续时间
    
    //如果回退 或者 快进后需要重新获取该时间片断下的弹幕
    if (self.isPreFilter || interval<0 || interval>kDanmakuFilterInterval) {
        NSLog(@"快进或者后退了，重新从弹幕池获取需要显示的弹幕...");
        self.isPreFilter = NO;
        self.curDanmakus = [TYDanmakuFilter filterDanmakus:self.danmakus time:_danmakuTime];
    }
    
    BOOL isBuffering = [self.delegate danmakuViewIsBuffering:self];
    [self.danmakuRenderer drawDanmakus:self.curDanmakus time:_danmakuTime isBuffering:isBuffering];
    
    _timeCount += kFrameInterval;
    if (_timeCount>kDanmakuFilterInterval) {
        _timeCount = 0;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *filterArray = [TYDanmakuFilter filterDanmakus:self.danmakus time:_danmakuTime];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.curDanmakus = filterArray;
            });
        });
    }
}

#pragma mark - add
- (void)addDanmakuSource:(id<TYDanmakuModelProtocol>)danmakuSource {
    
    __block NSMutableArray *newDanmakus = [NSMutableArray arrayWithArray:self.danmakus];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        id<TYDanmakuModelProtocol> lastDanmaku = newDanmakus.lastObject;
        if (newDanmakus.count<1 || danmakuSource.time > lastDanmaku.time) {
            [newDanmakus addObject:danmakuSource];
        } else {
            id<TYDanmakuModelProtocol> tempDanmaku = nil;
            for (NSInteger index=0; index<newDanmakus.count; index++) {
                tempDanmaku = newDanmakus[index];
                if (danmakuSource.time<tempDanmaku.time) {
                    [newDanmakus insertObject:danmakuSource atIndex:index];
                    break;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.danmakus = newDanmakus;
            self.isPreFilter = YES;
        });
    });
}


@end
