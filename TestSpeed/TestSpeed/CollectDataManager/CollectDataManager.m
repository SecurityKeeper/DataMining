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
#import "TouchWorker.h"

#define kSpeedFileName  @"加速计.txt"
#define kAngleFileName  @"旋转角度.txt"
#define kStepFileName   @"实时步数.txt"
#define mAngleFileName  @"角度.txt"
#define kTouchFileName  @"触摸.txt"

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
    dispatch_queue_t queue = dispatch_queue_create("checkQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^{
        [self getMontionInfo];
        [self getTouchInfo];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerWorking) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]run];
    });
}

- (void)stopWork {
    [self.timer invalidate];
    self.timer = nil;
    //停止速度、加速度、角度检测器
    [[MotionWorker shareInstance] stop];
    [[TouchWorker shareInstance] stopWork];
}

- (void)timerWorking {
    //获取实时步数量
    [self getHealthInfo];
}

- (void)getTouchInfo {
    [[TouchWorker shareInstance] startWork:^(CGPoint point) {
        NSString* str = [[NSString alloc]initWithFormat:@"触摸坐标Begin：x=%0.2f,y=%0.2f", point.x, point.y];
        [[FileManager shareInstance]writeFile:str WithFileName:kTouchFileName];
    } touchEnd:^(CGPoint point) {
        NSString* str = [[NSString alloc]initWithFormat:@"触摸坐标End：x=%0.2f,y=%0.2f", point.x, point.y];
        [[FileManager shareInstance]writeFile:str WithFileName:kTouchFileName];
    } touchMove:^(CGPoint point) {
        NSString* str = [[NSString alloc]initWithFormat:@"触摸坐标Move：x=%0.2f,y=%0.2f", point.x, point.y];
        [[FileManager shareInstance]writeFile:str WithFileName:kTouchFileName];
    }];
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
    
    
    [[MotionWorker shareInstance] startDeviceMotionUpdate:^(CMDeviceMotion *motion, NSError *error) {
        
        double roll = motion.attitude.roll; //roll是Y轴的转向，值减少的时候表示正往左边转，增加的时候往右；
        double pitch = motion.attitude.pitch; //pitch是X周方向的转动，增加的时候表示设备正朝你倾斜，减少的时候表示疏远；
        double yaw = motion.attitude.yaw;//yaw是Z轴转向，减少是时候是顺时针，增加的时候是逆时针。

//        NSLog(@"roll=%lf",roll);
//        NSLog(@"pitch=%lf",pitch);
//        NSLog(@"yaw=%lf",yaw);
        
        str = [NSString stringWithFormat:@"roll=:%.3f,pitch=%.3f,yaw=%.3f",roll,pitch,yaw];

        [[FileManager shareInstance]writeFile:str WithFileName:mAngleFileName];

    }];
}


- (void)getHealthInfo {
    if (![[HealthWorker shareInstance] checkDevice]) {
        messageBox(@"当前系统版本不支持获取健康数据信息");
        return;
    }
    
    [[HealthWorker shareInstance] getRealTimeStepCountCompletionHandler:^(double value, NSError *error) {
        NSString* str = [[NSString alloc]initWithFormat:@"当前步数：%d", (int)value];
        [[FileManager shareInstance]writeFile:str WithFileName:kStepFileName];
    }];
}

@end
