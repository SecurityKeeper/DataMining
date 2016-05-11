//
//  DMTouchDistanceModel.m
//  DataMining
//
//  Created by weiguang on 16/5/9.
//  Copyright © 2016年 SecurityKeeper. All rights reserved.
//

#import "DMTouchDistanceModel.h"
#import "DataStorageManager.h"
#import "CollectDataManager.h"
#import "DMTouchTimeModel.h"
#import "dataAnalysis.h"

@interface DMTouchDistanceModel()

@end

@implementation DMTouchDistanceModel

+ (DMTouchDistanceModel *)defaultInstance{
    static dispatch_once_t token;
    static DMTouchDistanceModel *model = nil;
    dispatch_once(&token, ^{
        model = [[DMTouchDistanceModel alloc] init];
    });
    return model;
}

- (double)getProbability:(NSArray *)newValue{
    NSArray *dataArray = [self loadData];
    NSArray *newValueArray = [self getNewArray:newValue];
    double result =  [[dataAnalysis defaultInstance] analysis:dataArray newVlue:newValueArray];
    return result;
}

/** 加载数据 */
- (NSArray *)loadData {
    NSArray * tempArray = [[DataStorageManager shareInstance] getDataType:entitiesType_Touch WithCount:0 dataFrom:dataSrcType_reliableStorage];
    NSArray *dataArray = [self getNewArray:tempArray];
    return dataArray;
}

//数据转换
- (NSArray *)getNewArray:(NSArray *)newValue{
    NSMutableArray *dataArry = [[NSMutableArray alloc] init];
    NSMutableArray *dataBeginX = [[NSMutableArray alloc] init];
    NSMutableArray *dataBeginY = [[NSMutableArray alloc] init];
    NSMutableArray *dataEndX = [[NSMutableArray alloc] init];
    NSMutableArray *dataEndY = [[NSMutableArray alloc] init];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    NSMutableArray *data2 = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in newValue) {
        if ([dict[@"touchType"] isEqual:@1]) {
            [dataBeginX addObject:dict[@"x"]];
            [dataBeginY addObject:dict[@"y"]];
        } else if ([dict[@"touchType"] isEqual:@3]){
            
            [dataEndX addObject:dict[@"x"]];
            [dataEndY addObject:dict[@"y"]];
        }
    }
    //求出起始点和终止点的距离
    for (int i = 0; i<dataEndX.count; i++) {
        double X = [dataBeginX[i] floatValue] - [dataEndX[i] floatValue];
        double Y = [dataBeginY[i] floatValue] - [dataEndY[i] floatValue];
        double dis = sqrt(X * X + Y * Y);
        if (dis == 0) {
            [data2 addObject:@(i)];
        } else{
            [data addObject:@(dis)];
        }
    }
    
    NSMutableIndexSet *set=[NSMutableIndexSet indexSet];
    for(NSNumber *temp in data2)
    {
        [set addIndex:[temp intValue]];
    }
    NSMutableArray *timeArray  = [self getTouchTime:newValue];
    [timeArray removeObjectsAtIndexes:set];
    for (int i = 0; i< data.count; i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:timeArray[i] forKey:@"x"];
        [dict setObject:data[i] forKey:@"y"];
        [dataArry addObject:dict];
    }
    
    return dataArry;
}

- (NSMutableArray *)getTouchTime:(NSArray *)valueArray {
    NSMutableArray * arrTemp = [NSMutableArray array];
    NSNumber *startTime = @0;
    NSNumber *stopTime = @0;
    for (NSDictionary * dic in valueArray) {
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
