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

//==================上层调用  取数据==================
- (NSArray*)getDataType:(entitiesType)type WithCount:(int)count;  
- (void)removeAllTempStorageData;
- (void)moveTempToReliableStorage;

//==================下层调用  存数据==================
- (void)saveType:(entitiesType)type WithData:(NSDictionary*)dict;

@end
