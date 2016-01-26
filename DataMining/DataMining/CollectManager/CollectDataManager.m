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
#import "LocationWorker.h"
#import "CoreDataManager.h"
#import "DataStorageManager.h"

void messageBox(NSString* str) {
    UIAlertView* view = [[UIAlertView alloc]initWithTitle:@"" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [view show];
}

@interface CollectDataManager ()

@property (nonatomic, strong)NSTimer* timer;
@property (atomic, assign)int stepCount;
@property (atomic, assign)int distanceSize;

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

- (void)dealloc {
    [self stopWork];
}

- (void)startWork {
    //开启线程
    dispatch_queue_t queue = dispatch_queue_create("checkQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^{
        [self getMontionInfo];
        [self getTouchInfo];
        [self getLocationInfo];
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
    [[LocationWorker defaultLocation] stopUpdateLocation];
}

- (void)timerWorking {
    //获取实时步数量
    [self getHealthInfo];
}

- (void)getLocationInfo {
    [[LocationWorker defaultLocation] startUpdateLocation:^(NSDictionary * locationInfo) {
        NSMutableString * locationStr = [NSMutableString stringWithString:@""];
        [locationStr appendString:locationInfo[@"adCode"]];
        double longitude = [locationInfo[@"longitude"] doubleValue];
        double latitude = [locationInfo[@"latitude"] doubleValue];
        
        [locationStr appendFormat:@", lng=%f, lat=%f",longitude,latitude];
        
        //[[FileManager shareInstance] writeFile:locationStr WithFileName:kLocationFileName];
        [[CoreDataManager shareInstance]addEntities:entitiesType_Location
                                           WithData:@{@"latitude":[NSNumber numberWithFloat:latitude],
                                                      @"longitude":[NSNumber numberWithFloat:longitude],
                                                      @"adCode":locationInfo[@"adCode"],
                                                      @"date":[NSDate date]}];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateLocationNotification" object:locationStr];
    }];
    
}

- (void)getTouchInfo {
    [[TouchWorker shareInstance] startWork:^(CGPoint point) {
        NSString* str = [[NSString alloc]initWithFormat:@"触摸坐标Begin：x=%0.2f,y=%0.2f", point.x, point.y];
        //[[FileManager shareInstance]writeFile:str WithFileName:kTouchFileName];
        [[CoreDataManager shareInstance]addEntities:entitiesType_Touch
                                           WithData:@{@"touchType":[NSNumber numberWithInt:touchType_begin],
                                                      @"x":[NSNumber numberWithFloat:point.x],
                                                      @"y":[NSNumber numberWithFloat:point.y],
                                                      @"date":[NSDate date]}];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTouchNotification" object:str];
    } touchEnd:^(CGPoint point) {
        NSString* str = [[NSString alloc]initWithFormat:@"触摸坐标End：x=%0.2f,y=%0.2f", point.x, point.y];
        //[[FileManager shareInstance]writeFile:str WithFileName:kTouchFileName];
        [[CoreDataManager shareInstance]addEntities:entitiesType_Touch
                                           WithData:@{@"touchType":[NSNumber numberWithInt:touchType_end],
                                                      @"x":[NSNumber numberWithFloat:point.x],
                                                      @"y":[NSNumber numberWithFloat:point.y],
                                                      @"date":[NSDate date]}];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTouchNotification" object:str];
    } touchMove:^(CGPoint point) {
        NSString* str = [[NSString alloc]initWithFormat:@"触摸坐标Move：x=%0.2f,y=%0.2f", point.x, point.y];
        //[[FileManager shareInstance]writeFile:str WithFileName:kTouchFileName];
        [[CoreDataManager shareInstance]addEntities:entitiesType_Touch
                                           WithData:@{@"touchType":[NSNumber numberWithInt:touchType_move],
                                                      @"x":[NSNumber numberWithFloat:point.x],
                                                      @"y":[NSNumber numberWithFloat:point.y],
                                                      @"date":[NSDate date]}];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTouchNotification" object:str];

    }];
}

- (void)getMontionInfo {
    if (![[MotionWorker shareInstance]checkDevice]) {
        messageBox(@"当前系统版本不支持获取加速度、角度信息");
        return;
    }
    
    __block NSString* str = nil;
    
    [[MotionWorker shareInstance]startMotionManagerWork:^(CMGyroData *gyroData, NSError *error) {
//        str = [NSString stringWithFormat:@"旋转角度:X:%.3f,Y:%.3f,Z:%.3f",gyroData.rotationRate.x,gyroData.rotationRate.y,gyroData.rotationRate.z];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGyroDataNotification" object:str];

//        [[FileManager shareInstance]writeFile:str WithFileName:kAngleFileName];
    } accelerometer:^(CMAccelerometerData *accelerometerData, NSError *error) {
        str = [NSString stringWithFormat:@"加速计:X:%.3f,Y:%.3f,Z:%.3f",accelerometerData.acceleration.x,accelerometerData.acceleration.y,accelerometerData.acceleration.z];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateAccelerometerNotification" object:str];

        //[[FileManager shareInstance]writeFile:str WithFileName:kSpeedFileName];
        [[CoreDataManager shareInstance]addEntities:entitiesType_Accelerometer
                                           WithData:@{@"z":[NSNumber numberWithFloat:accelerometerData.acceleration.z],
                                                      @"x":[NSNumber numberWithFloat:accelerometerData.acceleration.x],
                                                      @"y":[NSNumber numberWithFloat:accelerometerData.acceleration.y],
                                                      @"date":[NSDate date]}];
    }];
    
    
    [[MotionWorker shareInstance] startDeviceMotionUpdate:^(CMDeviceMotion *motion, NSError *error) {
        
        double roll = motion.attitude.roll; //roll是Y轴的转向，值减少的时候表示正往左边转，增加的时候往右；
        double pitch = motion.attitude.pitch; //pitch是X周方向的转动，增加的时候表示设备正朝你倾斜，减少的时候表示疏远；
        double yaw = motion.attitude.yaw;   //yaw是Z轴转向，减少是时候是顺时针，增加的时候是逆时针。
        
        str = [NSString stringWithFormat:@"pitch=%.3f,roll=%.3f,yaw=%.3f",pitch,roll,yaw];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateMotionNotification" object:str];
        
        //[[FileManager shareInstance]writeFile:str WithFileName:mAngleFileName];
        
        [[CoreDataManager shareInstance]addEntities:entitiesType_DeviceMontion
                                           WithData:@{@"pitch":[NSNumber numberWithFloat:pitch],
                                                      @"roll":[NSNumber numberWithFloat:roll],
                                                      @"yaw":[NSNumber numberWithFloat:yaw],
                                                      @"date":[NSDate date]}];
    }];
}

- (void)getHealthInfo {
    if (![[HealthWorker shareInstance] checkDevice]) {
        messageBox(@"当前系统版本不支持获取健康数据信息");
        return;
    }

    __weak typeof(self) weakSelf = self;
    [[HealthWorker shareInstance] getRealTimeStepCountCompletionHandler:^(double stepValue, NSError *error) {
        NSString* str = [[NSString alloc]initWithFormat:@"当前步数：%d步", (int)stepValue];
        //[[FileManager shareInstance]writeFile:str WithFileName:kStepFileName];
        weakSelf.stepCount = (int)stepValue;
        [[CoreDataManager shareInstance]addEntities:entitiesType_Health
                                           WithData:@{@"distance":[NSNumber numberWithInt:_distanceSize],
                                                      @"stepCount":[NSNumber numberWithInt:(int)stepValue],
                                                      @"date":[NSDate date]}];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateStepNotification" object:str];
    } distance:^(double distanceValue, NSError *error) {
        NSString* str = [[NSString alloc]initWithFormat:@"当前行走距离：%d米", (int)distanceValue];
        //[[FileManager shareInstance]writeFile:str WithFileName:kDistanceFileName];
        weakSelf.distanceSize = distanceValue;
        [[CoreDataManager shareInstance]addEntities:entitiesType_Health
                                           WithData:@{@"distance":[NSNumber numberWithInt:(int)distanceValue],
                                                      @"stepCount":[NSNumber numberWithInt:_stepCount],
                                                      @"date":[NSDate date]}];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDistanceNotification" object:str];
    }];
}

@end
