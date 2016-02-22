//
//  HealthModel.h
//  DataMining
//
//  Created by liuxu on 16/2/19.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HealthModel : NSObject

+ (HealthModel*)shareInstance;
- (void)initAnalyzeData;
- (void)currentAnalyzeData;

@end
