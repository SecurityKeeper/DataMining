//
//  CoreDataManager.h
//  DataMining
//
//  Created by liuxu on 16/1/22.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@interface CoreDataManager : NSObject

+ (CoreDataManager*)shareInstance;
- (BOOL)addEntities:(entitiesType)type WithData:(NSDictionary*)dict;    //添加一列数据
- (NSArray*)getEntitiesData:(entitiesType)type WithCount:(int)count;    //获取前count个数据
- (void)deleteEntities:(entitiesType)type WithCount:(int)count;         //删除前count个数据

@end
