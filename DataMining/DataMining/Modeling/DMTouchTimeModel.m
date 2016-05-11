//
//  DMTouchTimeModel.m
//  DataMining
//
//  Created by 郑红 on 2/18/16.
//  Copyright © 2016 SecurityKeeper. All rights reserved.
//

#import "DMTouchTimeModel.h"
#import "DataStorageManager.h"
#import "CollectorDef.h"
#import "DAAverageCalculate.h"

@interface DMTouchTimeModel ()
{
    
}
@end

@implementation DMTouchTimeModel

+ (DMTouchTimeModel *)defaultInstance {
    static dispatch_once_t token;
    static DMTouchTimeModel * model = nil;
    dispatch_once(&token, ^{
        model = [[DMTouchTimeModel alloc] init];
    });
    return model;
}

- (long double)getProbability:(NSArray *)newValue {
    NSArray * reliableTouchArray = [self getReliableTouchTime];
    if (reliableTouchArray.count == 0) {
        return 1;
    }
    NSArray * newTouchTimeArray = [self getTouchTimeArray:newValue];
    if (newTouchTimeArray.count == 0) {
        return 0;
    }
    
    long double totalResult = 0;
    for (NSNumber * touch in newTouchTimeArray) {
        long double result  =[[DAAverageCalculate defaultInstance] probabilityCalculate:reliableTouchArray newValue:[touch doubleValue]];
        totalResult += result;
    }
    
    return totalResult/newTouchTimeArray.count;
}


- (NSArray *)getReliableTouchTime {
    NSArray * tempArray = [[DataStorageManager shareInstance] getDataType:entitiesType_Touch WithCount:0 dataFrom:dataSrcType_reliableStorage];
    return [self getTouchTimeArray:tempArray];
}

- (NSArray *)getTouchTimeArray:(NSArray *)touchArray {
    NSMutableArray * arrTemp = [NSMutableArray array];
    NSNumber *startTime = @0;
    NSNumber *stopTime = @0;
    BOOL isRightData = YES;
    for (NSDictionary * dic in touchArray) {
        NSInteger touckType = [[dic objectForKey:kTouchType] integerValue];
        switch (touckType) {
            case 1:
            {
                startTime = [dic objectForKey:kTimesTamp];
                isRightData = YES;
                
            }
                break;
            case 2:
            {
                isRightData = false;
                startTime = @0;
            }
                break;
            default:
            {
                if (isRightData) {
                    stopTime = [dic objectForKey:kTimesTamp];
                    double time = fabs([stopTime doubleValue] - [startTime doubleValue]);
                    [arrTemp addObject:[NSNumber numberWithDouble:time]];
                    
                }
                
            }
                break;
        }
    }
    
    return [arrTemp mutableCopy];
}

@end
