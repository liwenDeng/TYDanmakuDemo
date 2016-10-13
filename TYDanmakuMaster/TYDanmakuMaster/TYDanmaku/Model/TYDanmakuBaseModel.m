//
//  TYBaseDanmukuModel.m
//  TYDanmakuMaster
//
//  Created by 邓利文 on 2016/10/12.
//  Copyright © 2016年 邓利文. All rights reserved.
//

#import "TYDanmakuBaseModel.h"

@implementation TYDanmakuBaseModel

- (void)rendererLabelWithConfig:(TYDanmakuConfig *)config {
    [self measureSizeWithPaintHeight:config.trajectoryHeight];
    self.label.alpha = 1;
    self.label.font = [UIFont systemFontOfSize:self.textSize];
    self.label.text = self.text;
    self.label.textColor = self.textColor;
}

- (void)measureSizeWithPaintHeight:(CGFloat)paintHeight;
{
    if (self.isMeasured) {
        return;
    }
    self.size = CGSizeMake([self.text sizeWithFont:[UIFont systemFontOfSize:self.textSize]].width, paintHeight);
    self.isMeasured = YES;
}

- (void)layoutWithScreenWidth:(CGFloat)width;
{
    self.px = [self pxWithScreenWidth:width remainTime:self.remainTime];
}

- (CGFloat)pxWithScreenWidth:(CGFloat)width remainTime:(CGFloat)remainTime
{
    return -self.size.width+(width+self.size.width)/self.duration*remainTime;
}

@end

@implementation TYDanmakuLRModel


@end

@implementation TYDanmakuFTModel

- (void)layoutWithScreenWidth:(CGFloat)width;
{
    self.px = (width-self.size.width)/2;
    float alpha = 0;
    if (self.remainTime>0 && self.remainTime<self.duration) {
        alpha= 1;
    }
    self.label.alpha = alpha;
}

@end

@implementation TYDanmakuFBModel

- (void)layoutWithScreenWidth:(CGFloat)width;
{
    self.px = (width-self.size.width)/2;
    float alpha = 0;
    if (self.remainTime>0 && self.remainTime<self.duration) {
        alpha= 1;
    }
    self.label.alpha = alpha;
}

@end
