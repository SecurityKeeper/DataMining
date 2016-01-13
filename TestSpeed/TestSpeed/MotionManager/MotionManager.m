//
//  MotionManager.m
//  TestSpeed
//
//  Created by liuxu on 16/1/13.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import "MotionManager.h"

@interface MotionManager()

@property (nonatomic,strong) CMMotionManager* motionManager;

@end

@implementation MotionManager

+ (MotionManager*)shareInstance {
    static MotionManager* mgr = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        if (!mgr) {
            mgr = [[MotionManager alloc]init];
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
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
        gyroDataBlock(gyroData, error);
    }];
    
    self.motionManager.accelerometerUpdateInterval=0.1;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        accelerometerBlock(accelerometerData, error);
    }];
}

- (void)stop {
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopGyroUpdates];
}

@end
