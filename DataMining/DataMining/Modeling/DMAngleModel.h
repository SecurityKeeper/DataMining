//
//  DMAngleModel.h
//  DataMining
//
//  Created by zhaoxiaoyun on 16/4/1.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataStorageManager.h"
#import "DAClustering.h"


@interface DMAngleModel : NSObject


+ (DMAngleModel *)sharedInstance;

//欧拉角
- (float)getMontionAnalyzeData:(NSDictionary*)data;

//加速计
- (float)getAccelerometerAnalyzeData:(NSDictionary*)data;
@end
