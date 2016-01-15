//
//  DataBaseManager.h
//  TestSpeed
//
//  Created by liuxu on 16/1/14.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBaseWorker : NSObject

- (BOOL)initDataBaseWorker:(NSString*)dataBaseName;
- (void)unInitDataBaseWorker;
- (void)deleteDataBase;
- (BOOL)createTable:(NSString*)tableName withFields:(NSArray*)fields;   //array is dictionary {"field","type"}
- (BOOL)insertIntoTable:(NSString*)tableName withField:(NSString*)field withValue:(NSString*)value;
- (BOOL)insertIntoTable:(NSString*)tableName withDatas:(NSArray*)datas; //array is dictionary {"field","value"}
- (BOOL)deleteTable:(NSString*)tableName;
- (NSArray*)queryAllDataFromTable:(NSString*)tableName;

@end
