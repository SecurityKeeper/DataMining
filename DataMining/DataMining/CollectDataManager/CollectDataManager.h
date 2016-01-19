//
//  CollectDataManager.h
//  TestSpeed
//
//  Created by liuxu on 16/1/13.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollectDataManager : NSObject

+ (CollectDataManager*)shareInstance;
- (void)startWork;
- (void)stopWork;

@end
