//
//  FileManager.m
//  TestSpeed
//
//  Created by liuxu on 16/1/13.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import "FileManager.h"

#define kLogFileName @"logFile.txt"

@implementation FileManager

+ (FileManager*)shareInstance {
    static FileManager* mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[FileManager alloc]init];
    });
    
    return mgr;
}

- (BOOL)writeLogFile:(NSString*)str {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* dateStr = [formatter stringFromDate:[NSDate date]];
    NSString* log = [NSString stringWithFormat:@"%@时间：%@\r\n", str, dateStr];

    return [self appendWriteFile:log WithFileName:kLogFileName];
}

- (BOOL)appendWriteFile:(NSString*)str WithFileName:(NSString*)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString* strFile = [docDir stringByAppendingFormat:@"/%@", fileName];
    NSLog(@"logFilePath = \r\n%@", strFile);
    NSFileManager* fileMgr = [[NSFileManager alloc]init];
    if (![fileMgr fileExistsAtPath:strFile]) {
        BOOL isCreate = [fileMgr createFileAtPath:strFile contents:nil attributes:nil];
        if (!isCreate) return NO;
    }
    NSFileHandle* outFile = [NSFileHandle fileHandleForWritingAtPath:strFile];
    if (!outFile) return NO;
    [outFile seekToEndOfFile];
    
    NSString* writeData = nil;
    if (!outFile.offsetInFile) {
        writeData = [[NSMutableString alloc]initWithFormat:@"%@",str];
    }
    else {
        writeData = [[NSMutableString alloc]initWithFormat:@"\r\n%@",str];
    }
    NSData *buffer = [writeData dataUsingEncoding:NSUTF8StringEncoding];
    [outFile writeData:buffer];
    [outFile synchronizeFile];
    [outFile closeFile];
    
    return YES;
}

@end
