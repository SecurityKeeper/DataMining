//
//  DAClustering.m
//  DataAnalysis
//
//  Created by Jiao Liu on 1/19/16.
//  Copyright (c) 2016 SecurityKeeper. All rights reserved.
//

#import "DAClustering.h"

@implementation DAClustering

static DAClustering *clusterInstance = nil;

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        clusterInstance = [[DAClustering alloc] init];
    });
    return clusterInstance;
}

+ (void)destroyInstance
{
    clusterInstance = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        averageDistance = 0;
        minDistance = MAXFLOAT;
    }
    return self;
}

#pragma mark - Canopy

- (float)calculateDistance:(NSDictionary *)dataOne Two:(NSDictionary *)dataTwo
{
    float distance = 0;
    NSArray *keysArray = [dataOne allKeys];
    for (NSString *key in keysArray) {
        float valueOne = [[dataOne objectForKey:key] floatValue];
        float valueTwo = [[dataTwo objectForKey:key] floatValue];
        distance += (valueOne - valueTwo) * (valueOne - valueTwo);
    }
    return distance;
}

- (void)calculateDistanceInfo:(NSArray *)data
{
    float totalDistance = 0;
    long num = 0;
    for (long i = 0; i < data.count; i++) {
        NSDictionary *oneData = [data objectAtIndex:i];
        for (long j = i + 1; j < data.count; j++) {
            NSDictionary *twoData = [data objectAtIndex:j];
            float distance = [self calculateDistance:oneData Two:twoData];
            if (distance <= minDistance) {
                minDistance = distance;
            }
            totalDistance += distance;
            num++;
        }
    }
    averageDistance = totalDistance / num;
}

- (NSArray *)canopyData:(NSArray *)data
{
    NSMutableArray *tempArray = [NSMutableArray array];
    NSMutableArray *retArray = [NSMutableArray arrayWithArray:data];
    NSDictionary *checkObject = [data objectAtIndex:0];
    [tempArray addObject:checkObject];
    for (int i = 1; i < data.count; i++) {
        NSDictionary *currentObject = [data objectAtIndex:i];
        if ([self calculateDistance:checkObject Two:currentObject] <= averageDistance) {
            [tempArray addObject:currentObject];
        }
    }
    [retArray removeObjectsInArray:tempArray];
    return retArray;
}

- (long)getTargetKValue:(NSArray *)data
{
    if (data.count == 0) { // No Input
        return 0;
    }
    long kValue = 0;
    [self calculateDistanceInfo:data];
    NSArray *tempArray = [NSArray arrayWithArray:data];
    while (tempArray.count != 0) {
        tempArray = [self canopyData:tempArray];
        kValue++;
    }
    return kValue;
}

#pragma mark - K-Mean

- (NSMutableArray *)reCenterArray:(NSMutableArray *)data
{
    NSMutableArray *retArray = [NSMutableArray array];
    for (NSMutableArray *item in data) {
        NSArray *keysArray = [[item objectAtIndex:0] allKeys];
        NSMutableDictionary *retItem = [NSMutableDictionary dictionary];
        for (NSString *key in keysArray) {
            float keyValue = 0;
            for (NSDictionary *dic in item) {
                keyValue += [[dic objectForKey:key] floatValue] / item.count;
            }
            [retItem setObject:[NSNumber numberWithFloat:keyValue] forKey:key];
        }
        [retArray addObject:retItem];
    }
    return retArray;
}

- (NSArray *)clusteringData:(NSArray *)data type:(kClusteringType)type
{
    NSMutableArray *centerArray = [NSMutableArray array];
    NSMutableArray *tempArray = [NSMutableArray array];
    NSMutableArray *sortDataArray;
    long kValue = [self getTargetKValue:data];
    for (long i = 0; i < kValue; i++) {
        [centerArray addObject:[data objectAtIndex:i]];
    }
    while (![tempArray isEqual:centerArray]) {
        tempArray = [NSMutableArray arrayWithArray:centerArray];
        sortDataArray = [NSMutableArray arrayWithCapacity:centerArray.count];
        for (int i = 0; i < centerArray.count; i++) {
            [sortDataArray addObject:[NSMutableArray array]];
        }
        for (NSDictionary *item in data) {
            float minDis = MAXFLOAT;
            long index = 0;
            for (long i = 0; i < tempArray.count; i++) {
                float distance = [self calculateDistance:item Two:[tempArray objectAtIndex:i]];
                if (distance <= minDis) {
                    minDis = distance;
                    index = i;
                }
            }
            NSMutableArray *updateArray = [sortDataArray objectAtIndex:index];
            if (updateArray == nil) {
                updateArray = [NSMutableArray array];
            }
            [updateArray addObject:item];
        }
        centerArray = [self reCenterArray:sortDataArray];
    }
    
    switch (type) {
        case kClusteringType_Grouped:
        {
            return sortDataArray;
        }
            break;
        case kClusteringType_Plain:
        {
            NSMutableArray *retArray = [NSMutableArray array];
            long clusterNum = 1;
            for (NSMutableArray *clusterArray in sortDataArray) {
                for (NSDictionary *item in clusterArray) {
                    NSMutableDictionary *tempItem = [NSMutableDictionary dictionaryWithDictionary:item];
                    [tempItem setObject:[NSNumber numberWithLong:clusterNum] forKey:@"cluster"];
                    [retArray addObject:tempItem];
                }
                clusterNum++;
            }
            
            return retArray;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Clustering Analysis

- (float)checkData:(NSDictionary *)data set:(NSArray *)dataSet
{
    float weight = 0.0;
    NSMutableArray *combinedData = [NSMutableArray arrayWithArray:dataSet];
    [combinedData addObject:data];
    long preKValue = [self getTargetKValue:dataSet];
    long postKValue = [self getTargetKValue:combinedData];
    if (preKValue != postKValue) {
        weight = 1.0 / combinedData.count;
    }
    else
    {
        NSArray *clusteredArray = [self clusteringData:combinedData type:kClusteringType_Grouped];
        for (NSArray *group in clusteredArray) {
            if ([group containsObject:data]) {
                weight = (float)group.count / combinedData.count;
                break;
            }
        }
    }
    return weight;
}

@end
