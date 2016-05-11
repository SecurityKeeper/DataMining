//
//  dataAnalysis.h
//  signLiner
//
//  Created by weiguang on 16/1/15.
//  Copyright (c) 2016年 weiguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface dataAnalysis : NSObject

+ (dataAnalysis *)defaultInstance;
- (double)analysis:(NSArray *)dataArray newVlue:(NSArray *)newArray;

@end
