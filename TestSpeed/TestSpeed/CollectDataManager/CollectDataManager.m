//
//  CollectDataManager.m
//  TestSpeed
//
//  Created by liuxu on 16/1/13.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectDataManager.h"
#import "HealthWorker.h"
#import "MotionWorker.h"
#import "FileManager.h"

#define kSpeedFileName  @"加速计.txt"
#define kAngleFileName  @"旋转角度.txt"
#define kStepFileName   @"实时步数.txt"

void messageBox(NSString* str) {
    UIAlertView* view = [[UIAlertView alloc]initWithTitle:@"" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [view show];
}

@interface CollectDataManager ()

@property (nonatomic,strong)NSTimer* timer;

@end

@implementation CollectDataManager

+ (CollectDataManager*)shareInstance {
    static CollectDataManager* mgr = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        mgr = [[CollectDataManager alloc]init];
    });
    
    return mgr;
}

- (void)startWork {
    //开启线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerWorking) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]run];
    });
}

- (void)stopWork {
    [self.timer invalidate];
    self.timer = nil;
    //停止速度、加速度、角度检测器
    [[MotionWorker shareInstance] stop];
}

- (void)timerWorking {
    static BOOL isFirst = YES;
    //开启速度、加速度、角度检测器
    if (isFirst) {
        [self getMontionInfo];
        isFirst = NO;
    }
    //获取实时步数量
    [self getHealthInfo];
}

- (void)getMontionInfo {
    if (![[MotionWorker shareInstance]checkDevice]) {
        messageBox(@"当前系统版本不支持获取加速度、角度信息");
        return;
    }
    
    __block NSString* str = nil;
    [[MotionWorker shareInstance]startMotionManagerWork:^(CMGyroData *gyroData, NSError *error) {
        str = [NSString stringWithFormat:@"旋转角度:X:%.3f,Y:%.3f,Z:%.3f",gyroData.rotationRate.x,gyroData.rotationRate.y,gyroData.rotationRate.z];
        [[FileManager shareInstance]writeFile:str WithFileName:kAngleFileName];
    } accelerometer:^(CMAccelerometerData *accelerometerData, NSError *error) {
        str = [NSString stringWithFormat:@"加速计:X:%.3f,Y:%.3f,Z:%.3f",accelerometerData.acceleration.x,accelerometerData.acceleration.y,accelerometerData.acceleration.z];
        [[FileManager shareInstance]writeFile:str WithFileName:kSpeedFileName];
    }];
}

- (void)getHealthInfo {
    if (![[HealthWorker shareInstance]checkDevice]) {
        messageBox(@"当前系统版本不支持获取健康数据信息");
        return;
    }
    
    [[HealthWorker shareInstance] getRealTimeStepCountCompletionHandler:^(double value, NSError *error) {
        NSString* str = [[NSString alloc]initWithFormat:@"当前步数：%d", (int)value];
        [[FileManager shareInstance]writeFile:str WithFileName:kStepFileName];
    }];
}

@end
