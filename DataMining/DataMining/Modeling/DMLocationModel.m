//
//  DMLocationModel.m
//  DataMining
//
//  Created by dengjc on 16/3/30.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import "DMLocationModel.h"

@implementation DMLocationModel
+ (DMLocationModel *)sharedInstance {
    static dispatch_once_t token;
    static DMLocationModel * model = nil;
    dispatch_once(&token, ^{
        model = [[DMLocationModel alloc] init];
    });
    return model;
}

- (double)getWeight:(NSArray*)data {
    
    NSArray *dbData = [[DataStorageManager shareInstance]getDataType:entitiesType_Location WithCount:0 dataFrom:dataSrcType_reliableStorage];
    NSMutableArray *dataSet = [[NSMutableArray alloc]init];
    long time = dbData.count/ 500;
    long remain = dbData.count % 500;
    if (time > 0) {
        for (int i = 0; i < 500; i++) {
            long index = i * time;
            long loop = i == 499 ? (i + 1) * time + remain  : (i + 1) * time;
            double latitude;
            double longitude;
            int num = 0;
            NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc]init];
            while (index < loop) {
                NSDictionary *dic = [dbData objectAtIndex:index];
                latitude += [[dic objectForKey:kLatitude] floatValue];
                longitude += [[dic objectForKey:kLongitude] floatValue];
                num++;
                index++;
            }
            [tmpDic setObject:@(latitude / num) forKey:kLatitude];
            [tmpDic setObject:@(longitude / num) forKey:kLongitude];
            [dataSet addObject:tmpDic];
        }
    }
    else
    {
        for (NSDictionary *dic in dbData) {
            NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc]init];
            float latitude = [[dic objectForKey:kLatitude] floatValue];
            float longitude = [[dic objectForKey:kLongitude] floatValue];
            [tmpDic setObject:@(latitude) forKey:kLatitude];
            [tmpDic setObject:@(longitude) forKey:kLongitude];
            [dataSet addObject:tmpDic];
        }
    }


    if (dataSet.count == 0||data.count == 0) {
        return 0;
    }
    
    double sum = 0.0;
    for (NSDictionary *valueDic in data) {
        NSMutableDictionary *checkDic = [NSMutableDictionary dictionary];
        [checkDic setValue:[valueDic objectForKey:kLatitude] forKey:kLatitude];
        [checkDic setValue:[valueDic objectForKey:kLongitude] forKey:kLongitude];
        sum += [[DAClustering sharedInstance]checkData:checkDic set:dataSet];
    }
    
    return sum/data.count;
}
@end
