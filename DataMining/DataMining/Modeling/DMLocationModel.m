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

- (double)getWeight:(NSDictionary*)data {
    
    NSArray *dbData = [[DataStorageManager shareInstance]getDataType:entitiesType_Location WithCount:0 dataFrom:dataSrcType_reliableStorage];
    NSMutableArray *dataSet = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in dbData) {
        NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc]init];
        double latitude = [[dic objectForKey:@"latitude"] doubleValue];
        double longitude = [[dic objectForKey:@"longitude"] doubleValue];
        [tmpDic setObject:@(latitude) forKey:@"latitude"];
        [tmpDic setObject:@(longitude) forKey:@"longitude"];
        [dataSet addObject:tmpDic];
    }
    if (dataSet.count == 0||data == nil) {
        return 0;
    }
    return [[DAClustering sharedInstance]checkData:data set:dataSet];
}
@end
