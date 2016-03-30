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
#import "DMAverageCalculate.h"

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

- (long double)getProbability:(double)newValue {
    NSMutableArray * arrTemp = [self getTouchTime];
    long double result  =[[DMAverageCalculate defaultInstance] probabilityCalculate:arrTemp newValue:newValue];
    return result;
}

- (NSMutableArray *)getTouchTime {
    NSArray * tempArray = [[DataStorageManager shareInstance] getDataType:entitiesType_Touch WithCount:0 dataFrom:dataSrcType_reliableStorage];
    NSMutableArray * arrTemp = [NSMutableArray array];
    NSNumber *startTime = @0;
    NSNumber *stopTime = @0;
    for (NSDictionary * dic in tempArray) {
        NSInteger touckType = [[dic objectForKey:kTouchType] integerValue];
        switch (touckType) {
            case 1:
            {
                startTime = [dic objectForKey:kTimesTamp];
            }
                break;
            case 2:
            {
                
            }
                break;
            default:
            {
                stopTime = [dic objectForKey:kTimesTamp];
                double time = [stopTime doubleValue] - [startTime doubleValue];
                [arrTemp addObject:[NSNumber numberWithDouble:time]];
            }
                break;
        }
    }
    
    return arrTemp;
}


@end
