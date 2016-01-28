//
//  collectorDef.h
//  DataMining
//
//  Created by liuxu on 16/1/27.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#ifndef DataMining_collectorDef_h
#define DataMining_collectorDef_h

#import "FileManager.h"

typedef enum {
    entitiesType_DeviceMontion = 0,
    entitiesType_Location,
    entitiesType_Touch,
    entitiesType_Accelerometer,
    entitiesType_Health
}entitiesType;

typedef enum {
    touchType_begin = 1,
    touchType_move,
    touchType_end
}touchType;

typedef enum {
    dataSrcType_memory = 1,
    dataSrcType_tempStorage,
    dataSrcType_reliableStorage
}dataSrcType;

#define kDatabaseMaxSize                    100000      //10万条
#define kMemoryMaxSize                      1000        //1000条

#define kUpdateMotionNotification           @"UpdateMotionNotification"
#define kUpdateAccelerometerNotification    @"UpdateAccelerometerNotification"
#define kUpdateStepNotification             @"UpdateStepNotification"
#define kUpdateDistanceNotification         @"UpdateDistanceNotification"
#define kUpdateTouchNotification            @"UpdateTouchNotification"
#define kUpdateLocationNotification         @"UpdateLocationNotification"
#define kNotiScreenTouchBegin               @"notiScreenTouchBegin"
#define kNotiScreenTouchMove                @"notiScreenTouchMove"
#define kNotiScreenTouchEnd                 @"notiScreenTouchEnd"

#define kTimesTamp                          @"timesTamp"
#define kLatitude                           @"latitude"
#define kLongitude                          @"longitude"
#define kAdCode                             @"adCode"
#define kTouchType                          @"touchType"
#define kX                                  @"x"
#define kY                                  @"y"
#define kZ                                  @"z"
#define kPitch                              @"pitch"
#define kRoll                               @"roll"
#define kYaw                                @"yaw"
#define kDistance                           @"distance"
#define kStepCount                          @"stepCount"

#define kDeviceMotion                       @"DeviceMotion"
#define kDeviceMotion_Temp                  @"DeviceMotion_Temp"
#define kLocation                           @"Location"
#define kLocation_Temp                      @"Location_Temp"
#define kTouch                              @"Touch"
#define kTouch_Temp                         @"Touch_Temp"
#define kAccelerometer                      @"Accelerometer"
#define kAccelerometer_Temp                 @"Accelerometer_Temp"
#define kHealth                             @"Health"
#define kHealth_Temp                        @"Health_Temp"

#define kWriteLog(str)                      [[FileManager shareInstance]writeLogFile:   \
                                            [NSString stringWithFormat:                 \
                                            @"文件：%s\r\n函数：%s\r\n行号：%d\r\n描述：%@\r\n",  \
                                            __FILE__, __func__, __LINE__, str]]

#endif
