//
//  FileManager.h
//  TestSpeed
//
//  Created by liuxu on 16/1/13.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSpeedFileName      @"加速计.txt"
#define kAngleFileName      @"旋转角度.txt"
#define kStepFileName       @"实时步数.txt"
#define kDistanceFileName   @"实时距离.txt"
#define mAngleFileName      @"角度.txt"
#define kTouchFileName      @"触摸.txt"
#define kLocationFileName   @"location.txt"

@interface FileManager : NSObject

+ (FileManager*)shareInstance;

//追加写文件
- (BOOL)writeFile:(NSString*)str WithFileName:(NSString*)fileName;

@end
