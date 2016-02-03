//
//  DMAverageCalculate.m
//  DataMining
//
//  Created by 郑红 on 2/1/16.
//  Copyright © 2016 SecurityKeeper. All rights reserved.
//

#import "DMAverageCalculate.h"
#import "DataStorageManager.h"

@interface DMAverageCalculate ()

@property (nonatomic,copy) calculateResult resultValue;
@property (nonatomic,copy) NSArray * number;

@end

@implementation DMAverageCalculate

- (DMAverageCalculate *)sharedManager {
    static DMAverageCalculate * averageCalculate;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        averageCalculate = [[DMAverageCalculate alloc] init];
    });
    return averageCalculate;
}

- (void)calculateType:(entitiesType)numberType
                Value:(double)value
               result:(calculateResult)result {
    NSArray * arr = [[DataStorageManager shareInstance] getDataType:numberType WithCount:0 dataFrom:dataSrcType_reliableStorage];
    
    long double avrValue   = [self aveValue:_number newValue:value];
    long double valueTemp  = [self varianceAveValue:avrValue valueArr:_number newValue:value];
    long double resultTemp = [self conValue:_number.count+1 variance:valueTemp];
    if (result) {
        result(resultTemp);
    }
}

- (long double)conValue:(double)aveValue variance :(long double)variacne {
    long double varianceTemp = sqrt(variacne);
    long double n = sqrt(aveValue);
    long double result = varianceTemp * 1.96/n;//95%
    
    return result;
}

//均值
- (long double)aveValue:(NSArray *)numberArr newValue:(double) newValue{
    long double total = 0;
    for (NSNumber * number in numberArr) {
        total += [number doubleValue];
    }
    if (newValue) {
      total += newValue;
    }
    return newValue?total/(numberArr.count+1):total/(numberArr.count);
}
//方差
- (long double)varianceAveValue:(long double)aveValue
                       valueArr:(NSArray *)numberArr
                       newValue:(double)newValue{
    long double total = 0;
    for (NSNumber * number in numberArr) {
        long double temp = [number doubleValue];
        total += pow((temp - aveValue), 2);
    }
    if (newValue) {
        total += pow((newValue - aveValue), 2);
    }
  
    
    return newValue?total/(numberArr.count +1):total/numberArr.count;
}


@end
