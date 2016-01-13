//
//  TouchWorker.h
//  TestSpeed
//
//  Created by liuxu on 16/1/13.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^touchPoint)(CGPoint point);

@interface TouchWorker : NSObject

+ (TouchWorker*)shareInstance;
- (void)startWork:(touchPoint)touch;
- (void)stopWork;

@end
