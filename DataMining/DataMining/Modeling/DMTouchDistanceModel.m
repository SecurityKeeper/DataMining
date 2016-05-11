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
/** 加载数据 */
- (NSArray *)loadData {
    NSMutableArray *dataArry = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *dataBeginX = [[NSMutableArray alloc] init];
    NSMutableArray *dataBeginY = [[NSMutableArray alloc] init];
    NSMutableArray *dataEndX = [[NSMutableArray alloc] init];
    NSMutableArray *dataEndY = [[NSMutableArray alloc] init];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    NSMutableArray *data2 = [[NSMutableArray alloc] init];
  
    NSArray * tempArray = [[DataStorageManager shareInstance] getDataType:entitiesType_Touch WithCount:0 dataFrom:dataSrcType_reliableStorage];
    for (NSDictionary *dict in tempArray) {
        if ([dict[@"touchType"] isEqual:@1]) {
            [dataBeginX addObject:dict[@"x"]];
            [dataBeginY addObject:dict[@"y"]];
        } else if ([dict[@"touchType"] isEqual:@3]){
            
            [dataEndX addObject:dict[@"x"]];
            [dataEndY addObject:dict[@"y"]];
        }
    }
    
    //求出起始点和终止点的距离
    for (int i = 0; i< dataBeginX.count; i++) {
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
    NSMutableArray *timeArray  = [[DMTouchTimeModel defaultInstance] getTouchTime];
    [timeArray removeObjectsAtIndexes:set];
    
   // NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (int i = 0; i< data.count; i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:timeArray[i] forKey:@"x"];
        [dict setObject:data[i] forKey:@"y"];
        [dataArry addObject:dict];
    }
    return dataArry;
}

- (double)getProbability :(NSArray *) newValue{
    NSArray *dataArray = [self loadData];
    double result =  [[dataAnalysis defaultInstance] analysis:dataArray newVlue:newValue];
    return result;
}
@end
