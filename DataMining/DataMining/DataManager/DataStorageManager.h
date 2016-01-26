//
//  DataStorageManager.h
//  DataMining
//
//  Created by liuxu on 16/1/25.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataManager.h"

@interface DataStorageManager : NSObject

+ (DataStorageManager*)shareInstance;

- (void)saveType:(entitiesType)type WithData:(NSDictionary*)dict;
- (NSArray*)getDataType:(entitiesType)type WithCount:(NSUInteger)count;  
- (void)removeAllTempStorageData;
- (void)removeMemoryData;
- (void)moveTempToReliableStorage;

@end
