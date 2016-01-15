//
//  DataBaseManager.m
//  TestSpeed
//
//  Created by liuxu on 16/1/14.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import "DataBaseWorker.h"
#import <sqlite3.h>

@interface DataBaseWorker() {
    sqlite3 *db;
}

@property (nonatomic, copy)NSString *database_path;
@property (nonatomic, copy)NSArray* fields;
@property (nonatomic, copy)NSString* dataBaseName;

@end

@implementation DataBaseWorker

+ (DataBaseWorker*)shareInstance {
    static DataBaseWorker* mgr;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        mgr = [[DataBaseWorker alloc]init];
    });
    
    return mgr;
}

- (BOOL)initDataBaseWorker:(NSString*)dataBaseName {
    self.dataBaseName = dataBaseName;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    self.database_path = [documents stringByAppendingPathComponent:dataBaseName];
    
    if (sqlite3_open([self.database_path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"数据库打开失败");
        return NO;
    }

    return YES;
}

- (void)unInitDataBaseWorker {
    sqlite3_close(db);
}

- (void)deleteDataBase {
    [[NSFileManager defaultManager] removeItemAtPath:self.database_path error:nil];
}

- (BOOL)createTable:(NSString*)tableName withFields:(NSArray*)fields {
    self.fields = [NSArray arrayWithArray:fields];
    NSMutableString* str = [NSMutableString string];
    for (int i=0; i<fields.count; i++) {
        NSDictionary* dict = fields[i];
        if (!dict) continue;
        NSString* fieldName = [dict objectForKey:@"field"];
        NSString* type = [dict objectForKey:@"type"];
        str = (NSMutableString*)[str stringByAppendingFormat:@"%@ %@", fieldName, type];
        if (i < fields.count-1) {
            str = (NSMutableString*)[str stringByAppendingString:@","];
        }
    }
    
    NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS PERSONINFO (ID INTEGER PRIMARY KEY AUTOINCREMENT,%@", str];
    return [self execSql:sqlCreateTable];
}

- (BOOL)insertIntoTable:(NSString*)tableName withField:(NSString*)field withValue:(NSString*)value {
    NSString *sql = [NSString stringWithFormat:
                      @"INSERT INTO '%@' ('%@') VALUES ('%@')",
                      tableName, field, value];
    return [self execSql:sql];
}

- (BOOL)insertIntoTable:(NSString*)tableName withDatas:(NSArray*)datas {
    NSMutableString* fields = [NSMutableString string];
    NSMutableString* values = [NSMutableString string];
    fields = (NSMutableString*)[fields stringByAppendingString:@"("];
    values = (NSMutableString*)[values stringByAppendingString:@"("];
    for (int i=0; i<datas.count; i++) {
        NSDictionary* dict = datas[i];
        if (!dict) continue;
        NSString* fieldTemp = [NSString stringWithFormat:@"'%@'", [dict objectForKey:@"field"]];
        NSString* valueTemp = [NSString stringWithFormat:@"'%@'", [dict objectForKey:@"value"]];
        fields = (NSMutableString*)[fields stringByAppendingString:fieldTemp];
        values = (NSMutableString*)[values stringByAppendingString:valueTemp];
        if (i < datas.count-1) {
            fields = (NSMutableString*)[fields stringByAppendingString:@","];
            values = (NSMutableString*)[values stringByAppendingString:@","];
        }
    }
    fields = (NSMutableString*)[fields stringByAppendingString:@")"];
    values = (NSMutableString*)[values stringByAppendingString:@")"];
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO '%@' %@ VALUES %@", tableName, fields, values];

    return [self execSql:sql];
}

- (NSArray*)queryAllDataFromTable:(NSString*)tableName {
    NSMutableArray* retArray = [NSMutableArray array];
    NSString *sqlQuery = [[NSString alloc]initWithFormat:@"SELECT * FROM %@", tableName];
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        int index = 1;
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *temp = NULL;
            NSString* value = nil;
            int nTemp = 0;
            NSDictionary* dict = self.fields[index-1];
            if (!dict) continue;
            NSString* field = [dict objectForKey:@"field"];
            NSString* type = [dict objectForKey:@"type"];
            
            if ([type isEqualToString:@"TEXT"]) {
                temp = (char*)sqlite3_column_text(statement, index);
                value = [[NSString alloc]initWithUTF8String:temp];
            }
            else if ([type isEqualToString:@"INTEGER"]) {
                nTemp = sqlite3_column_int(statement, index);
                value = [[NSString alloc]initWithFormat:@"%d", nTemp];
            }
            else {
                //不支持。。
                continue;
            }
            NSDictionary* data = @{@"field":field, @"value":value};
            [retArray addObject:data];
     
            index++;
        }
    }

    return retArray;
}

- (BOOL)deleteTable:(NSString*)tableName {
    NSString* sql = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
    return [self execSql:sql];
}

- (BOOL)execSql:(NSString *)sql {
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"数据库操作数据失败!");
        return NO;
    }
    
    return YES;
}

@end
