//
//  DataStorageManager.h
//  DataMining
//
//  Created by liuxu on 16/1/25.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataManager.h"
#import "CollectorDef.h"

@interface DataStorageManager : NSObject

+ (DataStorageManager*)shareInstance;

//count =＝ 0则获取该数据源类型的全部数据
- (NSArray*)getDataType:(entitiesType)type WithCount:(NSUInteger)count dataFrom:(dataSrcType)src;

- (void)saveType:(entitiesType)type WithData:(NSDictionary*)dict storage:(dataSrcType)storage;
- (void)removeAllTempStorageData;
- (void)removeMemoryData;
- (void)moveMemoryDataToTempStorage;
- (void)moveTempToReliableStorage;

@end
