//
//  TouchWorker.h
//  TestSpeed
//
//  Created by liuxu on 16/1/13.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^touchPointBegin)(CGPoint point);
typedef void(^touchPointEnd)(CGPoint point);

@interface TouchWorker : NSObject

+ (TouchWorker*)shareInstance;
- (void)startWork:(touchPointBegin)touchBegin
         touchEnd:(touchPointEnd)touchEnd;
- (void)stopWork;

@end
