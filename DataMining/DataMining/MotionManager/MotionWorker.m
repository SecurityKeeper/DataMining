//
//  MotionManager.m
//  TestSpeed
//
//  Created by liuxu on 16/1/13.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import "MotionWorker.h"

@interface MotionWorker()

@property (nonatomic,strong) CMMotionManager* motionManager;

@end

@implementation MotionWorker

+ (MotionWorker*)shareInstance {
    static MotionWorker* mgr = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        if (!mgr) {
            mgr = [[MotionWorker alloc]init];
        }
    });
    
    return mgr;
}

- (CMMotionManager*)motionManager {
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc]init];
    }
    return _motionManager;
}

- (BOOL)checkDevice {
    if (!self.motionManager.accelerometerAvailable) {
        return NO;
    }
    return YES;
}

- (void)startMotionManagerWork:(void(^)(CMGyroData *gyroData, NSError *error))gyroDataBlock
                 accelerometer:(void(^)(CMAccelerometerData *accelerometerData, NSError *error))accelerometerBlock {
    if (!self.motionManager.accelerometerAvailable) {
        return;
    }
    
    self.motionManager.gyroUpdateInterval = 0.1;  //更新频率是10Hz
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [self.motionManager startGyroUpdatesToQueue:queue withHandler:^(CMGyroData *gyroData, NSError *error) {
        gyroDataBlock(gyroData, error);
    }];
    
    self.motionManager.accelerometerUpdateInterval=0.1;
    [self.motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        accelerometerBlock(accelerometerData, error);
    }];
}



- (void)startDeviceMotionUpdate:(void(^)(CMDeviceMotion *motion, NSError *error))block {
    if (!_motionManager.deviceMotionAvailable) {
        return;
    }
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];

    _motionManager.deviceMotionUpdateInterval = 10.0/60.0;
    [_motionManager startDeviceMotionUpdatesToQueue:queue withHandler:^(CMDeviceMotion *motion, NSError *error) {
        
        if (block) {
            block(motion,error);
        }
    }];
}


- (void)stopDeviceMotion{
    if (_motionManager.deviceMotionActive) {
        [_motionManager stopDeviceMotionUpdates];
    }
}


- (void)stop {
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopGyroUpdates];
    [self stopDeviceMotion];
}

@end
