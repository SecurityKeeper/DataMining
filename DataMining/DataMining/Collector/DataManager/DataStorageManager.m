//
//  DataStorageManager.m
//  DataMining
//
//  Created by liuxu on 16/1/25.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import "DataStorageManager.h"

@interface DataStorageManager()

@property (nonatomic, strong)NSMutableArray* deviceMotionArray;
@property (nonatomic, strong)NSMutableArray* healthArray;
@property (nonatomic, strong)NSMutableArray* locationArray;
@property (nonatomic, strong)NSMutableArray* touchArray;
@property (nonatomic, strong)NSMutableArray* accelerometerArray;
@property (nonatomic, strong)NSTimer* timer;

@end

@implementation DataStorageManager

+ (DataStorageManager*)shareInstance {
    static DataStorageManager* data = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        data = [[DataStorageManager alloc]init];
        [data startThread];
    });
    
    return data;
}

- (NSMutableArray*)deviceMotionArray {
    if (!_deviceMotionArray) {
        _deviceMotionArray = [NSMutableArray array];
    }
    return _deviceMotionArray;
}

- (NSMutableArray*)healthArray {
    if (!_healthArray) {
        _healthArray = [NSMutableArray array];
    }
    return _healthArray;
}

- (NSMutableArray*)locationArray {
    if (!_locationArray) {
        _locationArray = [NSMutableArray array];
    }
    return _locationArray;
}

- (NSMutableArray*)touchArray {
    if (!_touchArray) {
        _touchArray = [NSMutableArray array];
    }
    return _touchArray;
}

- (NSMutableArray*)accelerometerArray {
    if (!_accelerometerArray) {
        _accelerometerArray = [NSMutableArray array];
    }
    return _accelerometerArray;
}

- (void)startThread {
    dispatch_queue_t queue = dispatch_queue_create("saveData", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^{
        //每隔10分钟将内存数据存入临时数据库中
        self.timer = [NSTimer scheduledTimerWithTimeInterval:60*10 target:self selector:@selector(timerWorking) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]run];
    });
}

- (void)timerWorking {
    [self moveMemoryDataToTempStorage];
    [self removeMoreData];
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
    [self moveMemoryDataToTempStorage]; //内存数据合并临时数据库
    [self moveTempToReliableStorage];   //临时数据库合并入可信数据库
    [self releaseArray];
}

- (void)releaseArray {
   @synchronized(self) {
        self.healthArray = nil;
        self.locationArray = nil;
        self.touchArray = nil;
        self.deviceMotionArray = nil;
        self.accelerometerArray = nil;
   }
}

- (void)removeMemoryData {
    [self releaseArray];
}

- (void)removeMoreData {
    @synchronized(self) {
        //移除数据库中超出最大额度的数据
        NSArray* typeArray = @[@0, @1, @2, @3, @4];
        for (NSNumber* num in typeArray) {
            entitiesType type = num.intValue;
            //临时
            NSUInteger count = [[CoreDataManager shareInstance] getTotalCount:type isTemp:YES];
            if (count >= kDatabaseMaxSize) {
                //删除前(kDatabaseMaxSize/2+(count-kDatabaseMaxSize))条数据
                NSUInteger deleteCount = kDatabaseMaxSize/2+(count-kDatabaseMaxSize);
                [[CoreDataManager shareInstance]deleteEntities_Temp:type WithCount:deleteCount];
            }
            //可信
            count = [[CoreDataManager shareInstance] getTotalCount:type isTemp:NO];
            if (count >= kDatabaseMaxSize) {
                //删除前(kDatabaseMaxSize/2+(count-kDatabaseMaxSize))条数据
                NSUInteger deleteCount = kDatabaseMaxSize/2+(count-kDatabaseMaxSize);
                [[CoreDataManager shareInstance]deleteEntities:type WithCount:deleteCount];
            }
        }
    }
}

- (NSArray*)getDataType:(entitiesType)type WithCount:(NSUInteger)count {
    //内存＋临时＋可信数据库
    NSMutableArray* dataArray = [NSMutableArray array];
    NSArray* tempArray = nil;
    NSArray* reliableArray = nil;
    @synchronized(self) {
        switch (type) {
            case entitiesType_DeviceMontion: {
                [dataArray addObjectsFromArray:self.deviceMotionArray];
                tempArray = [[CoreDataManager shareInstance]getEntitiesData_Temp:entitiesType_DeviceMontion];
                [dataArray addObjectsFromArray:tempArray];
                reliableArray = [[CoreDataManager shareInstance]getEntitiesData:entitiesType_DeviceMontion WithCount:count- tempArray.count - self.deviceMotionArray.count];
                [dataArray addObjectsFromArray:reliableArray];
            }
                break;
            case entitiesType_Location: {
                [dataArray addObjectsFromArray:self.locationArray];
                tempArray = [[CoreDataManager shareInstance]getEntitiesData_Temp:entitiesType_Location];
                [dataArray addObjectsFromArray:tempArray];
                reliableArray = [[CoreDataManager shareInstance]getEntitiesData:entitiesType_Location WithCount:count- tempArray.count - self.locationArray.count];
                [dataArray addObjectsFromArray:reliableArray];
            }
                break;
            case entitiesType_Touch: {
                [dataArray addObjectsFromArray:self.touchArray];
                tempArray = [[CoreDataManager shareInstance]getEntitiesData_Temp:entitiesType_Touch];
                [dataArray addObjectsFromArray:tempArray];
                reliableArray = [[CoreDataManager shareInstance]getEntitiesData:entitiesType_Touch WithCount:count- tempArray.count - self.touchArray.count];
                [dataArray addObjectsFromArray:reliableArray];
            }
                break;
            case entitiesType_Accelerometer: {
                [dataArray addObjectsFromArray:self.accelerometerArray];
                tempArray = [[CoreDataManager shareInstance]getEntitiesData_Temp:entitiesType_Accelerometer];
                [dataArray addObjectsFromArray:tempArray];
                reliableArray = [[CoreDataManager shareInstance]getEntitiesData:entitiesType_Accelerometer WithCount:count- tempArray.count - self.accelerometerArray.count];
                [dataArray addObjectsFromArray:reliableArray];
            }
                break;
            case entitiesType_Health: {
                [dataArray addObjectsFromArray:self.healthArray];
                tempArray = [[CoreDataManager shareInstance]getEntitiesData_Temp:entitiesType_Health];
                [dataArray addObjectsFromArray:tempArray];
                reliableArray = [[CoreDataManager shareInstance]getEntitiesData:entitiesType_Health WithCount:count- tempArray.count - self.healthArray.count];
                [dataArray addObjectsFromArray:reliableArray];
            }
                break;
        }
  
        return dataArray;
    }
}

- (void)removeAllTempStorageData {
    @synchronized(self) {
        NSArray* typeArray = @[@0, @1, @2, @3, @4];
        for (NSNumber* num in typeArray) {
            entitiesType type = num.intValue;
            NSUInteger totalCount = [[CoreDataManager shareInstance]getTotalCount:type isTemp:YES];
            [[CoreDataManager shareInstance] deleteEntities_Temp:type WithCount:totalCount];
        }
    }
}

- (void)saveType:(entitiesType)type WithData:(NSDictionary*)dict {
    //存入内存
    @synchronized(self) {
        switch (type) {
            case entitiesType_DeviceMontion:
                [self.deviceMotionArray addObject:dict];
                [self moveMoreDataToTempStorage:self.deviceMotionArray type:entitiesType_DeviceMontion];
                break;
            case entitiesType_Location:
                [self.locationArray addObject:dict];
                [self moveMoreDataToTempStorage:self.locationArray type:entitiesType_Location];
                break;
            case entitiesType_Touch:
                [self.touchArray addObject:dict];
                [self moveMoreDataToTempStorage:self.touchArray type:entitiesType_Touch];
                break;
            case entitiesType_Accelerometer:
                [self.accelerometerArray addObject:dict];
                [self moveMoreDataToTempStorage:self.accelerometerArray type:entitiesType_Accelerometer];
                break;
            case entitiesType_Health:
                [self.healthArray addObject:dict];
                [self moveMoreDataToTempStorage:self.healthArray type:entitiesType_Health];
                break;
        }
    }
}

- (void)moveMoreDataToTempStorage:(NSMutableArray*)array
                             type:(entitiesType)type {
    if (array.count >= kMemoryMaxSize) {
        for (NSDictionary* dict in array) {
            [[CoreDataManager shareInstance]addEntities_Temp:type WithData:dict];
        }
        [self removeMoreData];
        switch (type) {
            case entitiesType_DeviceMontion:
                self.deviceMotionArray = nil;
                break;
            case entitiesType_Location:
                self.locationArray = nil;
                break;
            case entitiesType_Touch:
                self.touchArray = nil;
                break;
            case entitiesType_Accelerometer:
                self.accelerometerArray = nil;
                break;
            case entitiesType_Health:
                self.healthArray = nil;
                break;
        }
    }
}

- (void)moveMemoryDataToTempStorage {
    //将数据从内存存入临时数据库
    @synchronized(self) {
        for (NSDictionary* dict in self.deviceMotionArray) {
            [[CoreDataManager shareInstance]addEntities_Temp:entitiesType_DeviceMontion WithData:dict];
        }
        for (NSDictionary* dict in self.locationArray) {
            [[CoreDataManager shareInstance]addEntities_Temp:entitiesType_Location WithData:dict];
        }
        for (NSDictionary* dict in self.touchArray) {
            [[CoreDataManager shareInstance]addEntities_Temp:entitiesType_Touch WithData:dict];
        }
        for (NSDictionary* dict in self.accelerometerArray) {
            [[CoreDataManager shareInstance]addEntities_Temp:entitiesType_Accelerometer WithData:dict];
        }
        for (NSDictionary* dict in self.healthArray) {
            [[CoreDataManager shareInstance]addEntities_Temp:entitiesType_Health WithData:dict];
        }
        [self releaseArray];
        [self removeMoreData];
    }
}

- (void)moveTempToReliableStorage {
    //将临时数据库中数据搬入可信数据库中
    @synchronized(self) {
        NSArray* typeArray = @[@0, @1, @2, @3, @4];
        for (NSNumber* num in typeArray) {
            entitiesType type = num.intValue;
            NSArray* array = [[CoreDataManager shareInstance]getEntitiesData_Temp:type];
            for (NSDictionary* dict in array) {
                [[CoreDataManager shareInstance]addEntities:type WithData:dict];
            }
            NSUInteger totalCount = [[CoreDataManager shareInstance]getTotalCount:type isTemp:YES];
            [[CoreDataManager shareInstance] deleteEntities_Temp:type WithCount:totalCount];
        }
        [self removeMoreData];
    }
}

@end
