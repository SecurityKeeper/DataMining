//
//  FileManager.h
//  TestSpeed
//
//  Created by liuxu on 16/1/13.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

+ (FileManager*)shareInstance;

//追加写文件
- (BOOL)writeFile:(NSString*)str WithFileName:(NSString*)fileName;

@end
