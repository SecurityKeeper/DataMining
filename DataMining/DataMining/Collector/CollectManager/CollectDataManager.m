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
#import "DataStorageManager.h"
#import "CollectorDef.h"

void messageBox(NSString* str) {
//    UIAlertView* view = [[UIAlertView alloc]initWithTitle:@"" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [view show];
    kWriteLog(str);
}

@interface CollectDataManager () {
    NSDictionary* _preHealthDict;
    NSDictionary* _preLocaltionDict;
    NSDictionary* _preMotionDict;
    NSDictionary* _preTouchDict;
    NSDictionary* _preaccelerometerDict;
}

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
    //将内存数据->临时数据库->可信数据库中
    [[DataStorageManager shareInstance]moveMemoryDataToTempStorage];
    [[DataStorageManager shareInstance]moveTempToReliableStorage];
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
        
        NSDictionary* dict = @{kLatitude:[NSNumber numberWithFloat:latitude],
                               kLongitude:[NSNumber numberWithFloat:longitude],
                               kAdCode:locationInfo[@"adCode"],
                               kTimesTamp:[self getTimeTamp]};
        if (![self checkDataIsChange:dict type:entitiesType_Location]) {
            return;
        }
        [[DataStorageManager shareInstance]saveType:entitiesType_Location WithData:dict storage:dataSrcType_memory];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateLocationNotification object:locationStr];
    }];
}

- (void)getTouchInfo {
    [[TouchWorker shareInstance] startWork:^(CGPoint point) {
        NSString* str = [[NSString alloc]initWithFormat:@"触摸坐标Begin：x=%0.2f,y=%0.2f", point.x, point.y];

        NSDictionary* dict = @{kTouchType:[NSNumber numberWithInt:touchType_begin],
                               kX:[NSNumber numberWithFloat:point.x],
                               kY:[NSNumber numberWithFloat:point.y],
                               kTimesTamp:[self getTimeTamp]};
        if (![self checkDataIsChange:dict type:entitiesType_Touch]) {
            return;
        }
        [[DataStorageManager shareInstance]saveType:entitiesType_Touch WithData:dict storage:dataSrcType_memory];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateTouchNotification object:str];
    } touchEnd:^(CGPoint point) {
        NSString* str = [[NSString alloc]initWithFormat:@"触摸坐标End：x=%0.2f,y=%0.2f", point.x, point.y];
        
        NSDictionary* dict = @{kTouchType:[NSNumber numberWithInt:touchType_end],
                               kX:[NSNumber numberWithFloat:point.x],
                               kY:[NSNumber numberWithFloat:point.y],
                               kTimesTamp:[self getTimeTamp]};
        if (![self checkDataIsChange:dict type:entitiesType_Touch]) {
            return;
        }
        [[DataStorageManager shareInstance]saveType:entitiesType_Touch WithData:dict storage:dataSrcType_memory];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateTouchNotification object:str];
    } touchMove:^(CGPoint point) {
        NSString* str = [[NSString alloc]initWithFormat:@"触摸坐标Move：x=%0.2f,y=%0.2f", point.x, point.y];
        
        NSDictionary* dict = @{kTouchType:[NSNumber numberWithInt:touchType_move],
                               kX:[NSNumber numberWithFloat:point.x],
                               kY:[NSNumber numberWithFloat:point.y],
                               kTimesTamp:[self getTimeTamp]};
        if (![self checkDataIsChange:dict type:entitiesType_Touch]) {
            return;
        }
        [[DataStorageManager shareInstance]saveType:entitiesType_Touch WithData:dict storage:dataSrcType_memory];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateTouchNotification object:str];
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
        
        NSDictionary* dict = @{kZ:[NSNumber numberWithFloat:accelerometerData.acceleration.z],
                               kX:[NSNumber numberWithFloat:accelerometerData.acceleration.x],
                               kY:[NSNumber numberWithFloat:accelerometerData.acceleration.y],
                               kTimesTamp:[self getTimeTamp]};
        if (![self checkDataIsChange:dict type:entitiesType_Accelerometer]) {
            return;
        }
        [[DataStorageManager shareInstance]saveType:entitiesType_Accelerometer WithData:dict storage:dataSrcType_memory];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateAccelerometerNotification
                                                            object:str];
    }];

    [[MotionWorker shareInstance] startDeviceMotionUpdate:^(CMDeviceMotion *motion, NSError *error) {
        
        double roll = motion.attitude.roll;     //roll是Y轴的转向，值减少的时候表示正往左边转，增加的时候往右；
        double pitch = motion.attitude.pitch;   //pitch是X周方向的转动，增加的时候表示设备正朝你倾斜，减少的时候表示疏远；
        double yaw = motion.attitude.yaw;       //yaw是Z轴转向，减少是时候是顺时针，增加的时候是逆时针。
        
        str = [NSString stringWithFormat:@"pitch=%.3f,roll=%.3f,yaw=%.3f",pitch,roll,yaw];

        NSDictionary* dict = @{kPitch:[NSNumber numberWithFloat:pitch],
                               kRoll:[NSNumber numberWithFloat:roll],
                               kYaw:[NSNumber numberWithFloat:yaw],
                               kTimesTamp:[self getTimeTamp]};
        if (![self checkDataIsChange:dict type:entitiesType_DeviceMontion]) {
            return;
        }
        [[DataStorageManager shareInstance]saveType:entitiesType_DeviceMontion WithData:dict storage:dataSrcType_memory];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateMotionNotification object:str];
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
        weakSelf.stepCount = (int)stepValue;
        
        NSDictionary* dict = @{kDistance:[NSNumber numberWithInt:_distanceSize],
                               kStepCount:[NSNumber numberWithInt:(int)stepValue],
                               kTimesTamp:[self getTimeTamp]};
        if (![weakSelf checkDataIsChange:dict type:entitiesType_Health]) {
            return;
        }
    
        [[DataStorageManager shareInstance]saveType:entitiesType_Health WithData:dict storage:dataSrcType_memory];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateStepNotification object:str];
    } distance:^(double distanceValue, NSError *error) {
        NSString* str = [[NSString alloc]initWithFormat:@"当前行走距离：%d米", (int)distanceValue];
        weakSelf.distanceSize = distanceValue;
        
        NSDictionary* dict = @{kDistance:[NSNumber numberWithInt:(int)distanceValue],
                               kStepCount:[NSNumber numberWithInt:_stepCount],
                               kTimesTamp:[weakSelf getTimeTamp]};
        if (![weakSelf checkDataIsChange:dict type:entitiesType_Health]) {
            return;
        }
        
        [[DataStorageManager shareInstance]saveType:entitiesType_Health WithData:dict storage:dataSrcType_memory];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateDistanceNotification object:str];
    }];
}

- (NSNumber*)getTimeTamp {
    double timesTamp = [[NSDate date] timeIntervalSince1970];
    NSNumber* numTamp = [NSNumber numberWithDouble:timesTamp];
    return numTamp;
}

- (BOOL)checkDataIsChange:(NSDictionary*)dict type:(entitiesType)type {
    //判断数据有无变化，无变化则不写入数据库中，防止出现很多相同的冗余数据
    switch (type) {
        case entitiesType_DeviceMontion:
            if (!_preMotionDict) {
                _preMotionDict = [NSDictionary dictionaryWithDictionary:dict];
            }
            else {
                float pitch = ((NSNumber*)[dict objectForKey:kPitch]).floatValue;
                float roll = ((NSNumber*)[dict objectForKey:kRoll]).floatValue;
                float yaw = ((NSNumber*)[dict objectForKey:kYaw]).floatValue;
       
                float prePitch = ((NSNumber*)[_preMotionDict objectForKey:kPitch]).floatValue;
                float preRoll = ((NSNumber*)[_preMotionDict objectForKey:kRoll]).floatValue;
                float preYaw = ((NSNumber*)[_preMotionDict objectForKey:kYaw]).floatValue;
                
                if (pitch == prePitch && roll == preRoll && yaw == preYaw) {
                    return NO;
                }
            }
            break;
        case entitiesType_Location:
            if (!_preLocaltionDict) {
                _preLocaltionDict = [NSDictionary dictionaryWithDictionary:dict];
            }
            else {
                float latitude = ((NSNumber*)[dict objectForKey:kLatitude]).floatValue;
                float longitude = ((NSNumber*)[dict objectForKey:kLongitude]).floatValue;
                NSString* adCode = [dict objectForKey:kAdCode];
                
                float preLatitude = ((NSNumber*)[_preLocaltionDict objectForKey:kLatitude]).floatValue;
                float preLongitude = ((NSNumber*)[_preLocaltionDict objectForKey:kLongitude]).floatValue;
                NSString* preAdCode = [_preLocaltionDict objectForKey:kAdCode];
                
                if (latitude == preLatitude && longitude == preLongitude && [adCode isEqualToString:preAdCode]) {
                    return NO;
                }
            }
            break;
        case entitiesType_Touch:
            if (!_preTouchDict) {
                _preTouchDict = [NSDictionary dictionaryWithDictionary:dict];
            }
            else {
                int touchType = ((NSNumber*)[dict objectForKey:kTouchType]).intValue;
                float x = ((NSNumber*)[dict objectForKey:kX]).floatValue;
                float y = ((NSNumber*)[dict objectForKey:kY]).floatValue;
                
                int preTouchType = ((NSNumber*)[_preMotionDict objectForKey:kTouchType]).intValue;
                float preX = ((NSNumber*)[_preMotionDict objectForKey:kX]).floatValue;
                float preY = ((NSNumber*)[_preMotionDict objectForKey:kY]).floatValue;
                
                if (touchType == preTouchType && x == preX && y == preY) {
                    return NO;
                }
            }
            break;
        case entitiesType_Accelerometer:
            if (!_preaccelerometerDict) {
                _preaccelerometerDict = [NSDictionary dictionaryWithDictionary:dict];
            }
            else {
                float x = ((NSNumber*)[dict objectForKey:kX]).floatValue;
                float y = ((NSNumber*)[dict objectForKey:kY]).floatValue;
                float z = ((NSNumber*)[dict objectForKey:kZ]).floatValue;
                
                float preX = ((NSNumber*)[_preMotionDict objectForKey:kX]).floatValue;
                float preY = ((NSNumber*)[_preMotionDict objectForKey:kY]).floatValue;
                float preZ = ((NSNumber*)[_preMotionDict objectForKey:kZ]).floatValue;
                
                if (x == preX && y == preY && z == preZ) {
                    return NO;
                }
            }
            break;
        case entitiesType_Health:
            if (!_preHealthDict) {
                _preHealthDict = [NSDictionary dictionaryWithDictionary:dict];
            }
            else {
                int distance = ((NSNumber*)[dict objectForKey:kDistance]).intValue;
                int stepCount = ((NSNumber*)[dict objectForKey:kStepCount]).intValue;
  
                int preDistance = ((NSNumber*)[_preMotionDict objectForKey:kDistance]).intValue;
                int preStepCount = ((NSNumber*)[_preMotionDict objectForKey:kStepCount]).intValue;

                if (distance == preDistance /*&&*/ || stepCount == preStepCount) {
                    return NO;
                }
            }
            break;
    }
    
    return YES;
}

@end
