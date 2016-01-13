//
//  MotionManager.h
//  TestSpeed
//
//  Created by liuxu on 16/1/13.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h> 

@interface MotionWorker : NSObject

+ (MotionWorker*)shareInstance;
- (BOOL)checkDevice;
- (void)startMotionManagerWork:(void(^)(CMGyroData *gyroData, NSError *error))gyroDataBlock
                 accelerometer:(void(^)(CMAccelerometerData *accelerometerData, NSError *error))accelerometerBlock;
- (void)stop;


- (void)startDeviceMotionUpdate:(void(^)(CMDeviceMotion *motion, NSError *error))block;

@end
