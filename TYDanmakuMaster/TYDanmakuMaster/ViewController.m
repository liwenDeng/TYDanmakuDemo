//
//  ViewController.m
//  TYDanmakuDemo
//
//  Created by 邓利文 on 2016/10/11.
//  Copyright © 2016年 邓利文. All rights reserved.
//

#import "ViewController.h"
#import "TYDanmakuView.h"
#import "TYDanmakuConfig.h"
#import "TYDanmakuBaseModel.h"

@interface ViewController () <TYDanmakuViewDelegate>

@property (nonatomic, strong) TYDanmakuView *danmakuView;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    TYDanmakuConfig *config = [[TYDanmakuConfig alloc]init];
    config.duration = 6.5;
    config.trajectoryHeight = 21;
    config.maxShowCount = 45;
    config.enableOverlap = YES;
    
    TYDanmakuView *dView = [[TYDanmakuView alloc]initWithFrame:self.view.bounds configuration:config];
    dView.delegate = self;
    self.danmakuView = dView;
    [self.view addSubview:dView];
    
    self.slider = [[UISlider alloc]initWithFrame:CGRectMake(20, 600, self.view.frame.size.width - 20, 30)];
    [self.view addSubview:self.slider];
    self.slider.maximumValue = 1.0f;
    self.slider.minimumValue = 0.0f;
    
    self.timeLabel = [[UILabel alloc]init];
    self.timeLabel.text = @"00000000";
    [self.timeLabel sizeToFit];
    self.timeLabel.center = CGPointMake(self.view.center.x, 500);
    [self.view addSubview:self.timeLabel];
    
    [self setupBtns];
}

- (void)setupBtns {
    UIButton *startBtn = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [startBtn setTitle:@"start" forState:(UIControlStateNormal)];
    [startBtn addTarget:self action:@selector(startClick) forControlEvents:(UIControlEventTouchUpInside)];
    [startBtn sizeToFit];
    startBtn.center = CGPointMake(50, 300);
    
    UIButton *pauseBtn = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [pauseBtn setTitle:@"pause" forState:(UIControlStateNormal)];
    [pauseBtn addTarget:self action:@selector(pauseBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
    [pauseBtn sizeToFit];
    pauseBtn.center = CGPointMake(100, 300);
    
    UIButton *stopBtn = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [stopBtn setTitle:@"stop" forState:(UIControlStateNormal)];
    [stopBtn addTarget:self action:@selector(stopBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
    [stopBtn sizeToFit];
    stopBtn.center = CGPointMake(150, 300);
    
    UIButton *sendBtn = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [sendBtn setTitle:@"send" forState:(UIControlStateNormal)];
    [sendBtn addTarget:self action:@selector(sendBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
    [sendBtn sizeToFit];
    sendBtn.center = CGPointMake(200, 300);
    
    [self.view addSubview:startBtn];
    [self.view addSubview:pauseBtn];
    [self.view addSubview:stopBtn];
    [self.view addSubview:sendBtn];
    
    NSString *danmakufile = [[NSBundle mainBundle] pathForResource:@"danmakufile" ofType:nil];
    NSArray *items = [NSArray arrayWithContentsOfFile:danmakufile];
    
    NSMutableArray *danmakus = [NSMutableArray arrayWithCapacity:items.count];
    for (NSDictionary *dic in items.objectEnumerator) {
        if ([dic isKindOfClass:[NSDictionary class]]) {
            NSString *pString = dic[@"p"];
            NSString *mString = dic[@"m"];
            
            if (pString.length<1 || mString.length<1) {
                continue;
            }
            NSArray *pArray = [pString componentsSeparatedByString:@","];
            if (pArray.count<5) {
                continue ;
            }
            
            TYDanmakuType type = arc4random() % 3;
            id<TYDanmakuModelProtocol> model = nil;
            switch (type) {
                case TYDanmakuTypeLR:
                    model = [[TYDanmakuLRModel alloc]init];
                    break;
                case TYDanmakuTypeFT:
                    model = [[TYDanmakuFTModel alloc]init];
                    break;
                    
                case TYDanmakuTypeFB:
                    model = [[TYDanmakuFBModel alloc]init];
                    break;
                default:
                    break;
            }
            model.danmakuType = type;
            model.duration = 6.5;
            model.time = [pArray[0] floatValue]/1000.0;
            model.text = mString;
            model.textSize = 14.0f;
        
            [danmakus addObject:model];
            
        }
    }
    [self.danmakuView prepareDanmakuSources:danmakus];
    
}

- (void)startClick {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTimeCount) userInfo:nil repeats:YES];
    }
    [self.danmakuView start];
}

- (void)pauseBtnClick {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [self.danmakuView pause];
}

- (void)stopBtnClick {
    [self.danmakuView stop];
}

- (void)sendBtnClick{
    TYDanmakuType type = arc4random() % 3;
    id<TYDanmakuModelProtocol> model = nil;
    switch (type) {
        case TYDanmakuTypeLR:
            model = [[TYDanmakuLRModel alloc]init];
            break;
        case TYDanmakuTypeFT:
            model = [[TYDanmakuFTModel alloc]init];
            break;
            
        case TYDanmakuTypeFB:
            model = [[TYDanmakuFBModel alloc]init];
            break;
        default:
            break;
    }
    model.danmakuType = type;
    model.duration = 6.5;
    model.time = ([self danmakuViewGetPlayTime:nil] + 1); //发送时间延迟一秒
    model.text = @"🍎This is Test Danmaku!🍎";
    model.textSize = 14.0f;
    [self.danmakuView addDanmakuSource:model];
}

- (void)onTimeCount
{
    _slider.value+=0.1/120;
    if (_slider.value>120.0) {
        _slider.value=0;
    }
    self.timeLabel.text = [NSString stringWithFormat:@"%.0fs", _slider.value*120.0];
}

#pragma mark -
- (CGFloat)danmakuViewGetPlayTime:(TYDanmakuView *)danmakuView
{
    return _slider.value*120.0;
}

- (BOOL)danmakuViewIsBuffering:(TYDanmakuView *)danmakuView
{
    return NO;
}

- (void)danmakuViewPerpareComplete:(TYDanmakuView *)danmakuView
{
    [_danmakuView start];
}


@end
