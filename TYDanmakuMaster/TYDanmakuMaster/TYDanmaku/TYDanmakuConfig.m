//
//  TYDanmakuConfig.m
//  TYDanmakuMaster
//
//  Created by 邓利文 on 2016/10/12.
//  Copyright © 2016年 邓利文. All rights reserved.
//

#import "TYDanmakuConfig.h"

@implementation TYDanmakuConfig

- (instancetype)init {
    if (self = [super init]) {
        //默认值
        self.fontSize = 14.0f;
        self.duration = 6.5f;
        self.trajectoryHeight = 21;
        self.maxShowCount = 9999;
        self.maxLRShowCount = 9999;
        self.showLineWhenSelf = NO;
    }
    return self;
}

@end
