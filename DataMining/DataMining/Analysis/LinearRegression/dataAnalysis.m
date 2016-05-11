//
//  dataAnalysis.m
//  signLiner
//
//  Created by weiguang on 16/1/15.
//  Copyright (c) 2016年 weiguang. All rights reserved.
//

#import "dataAnalysis.h"
#import "DAAverageCalculate.h"
#import "DataStorageManager.h"
#import "CollectorDef.h"
#import "DMTouchTimeModel.h"

@interface dataAnalysis()

@end

@implementation dataAnalysis

+ (dataAnalysis *)defaultInstance{
    static dispatch_once_t token;
    static dataAnalysis *model = nil;
    dispatch_once(&token, ^{
        model = [[dataAnalysis alloc] init];
    });
    return model;
    
}

- (long double)analysis:(NSArray *)dataArray newVlue:(NSArray *)newArray{
    int i, n = (int)dataArray.count;
    long double sumx,sumy,sumxx,sumyy,sumxy,mx,my,mxx,myy,mxy;
    long double a, b;
    long double d1, d2, d3;
    long double result;
    // 变量的初始化
    result = d1 = d2 = d3 = mx = my = sumx = sumy = sumxx = sumyy = sumxy = 0.0;
    NSMutableArray *dataX = [NSMutableArray array];
    NSMutableArray *dataY = [NSMutableArray array];
    
    for (NSDictionary *dict in dataArray){
        [dataX addObject:dict[@"x"]];
        [dataY addObject:dict[@"y"]];
    }
     // 计算data、data2的平均值
    for (i = 0; i<n; i++) {
        
        sumx += [[dataX objectAtIndex:i] floatValue];
        sumy += [[dataY objectAtIndex:i] floatValue];
    }
    mx = sumx / n; //x平均值
    my = sumy / n; //y平均值
   // printf("mx=%f my=%f\n",mx,my);
    
    // 计算x、y平和x*y的平均值
    for(i = 0;i<n;i++){
        
        sumxx += [[dataX objectAtIndex:i] floatValue] * [[dataX objectAtIndex:i] floatValue];  //x平方和
        sumyy += [[dataY objectAtIndex:i] floatValue] * [[dataY objectAtIndex:i] floatValue];//y平方和
        sumxy += [[dataX objectAtIndex:i] floatValue] * [[dataY objectAtIndex:i] floatValue]; //x*y求和
    }
    mxx = sumxx / n;
    myy = sumyy / n;
    mxy = sumxy / n;
   // printf("mxx=%f myy=%f mxy=%f\n",mxx,myy,mxy);
   //计算系数
    a=(n*sumxy-sumx*sumy)/(n*sumxx-sumx*sumx);
    b=(sumxx*sumy-sumx*sumxy)/(n*sumxx-sumx*sumx);
   // printf("a=%Lf b=%Lf\n",a,b);

    // 计算相关系数的数据组成部分,相关系数决定回归方程估测可靠程度的高低
    for (i = 0; i < n; i++) {
        d1 += ([dataX[i] floatValue] - mx) * ([dataY[i] floatValue] - my);
        d2 += ([dataX[i] floatValue] - mx) * ([dataX[i] floatValue] - mx);
        d3 += ([dataY[i] floatValue] - my) * ([dataY[i] floatValue] - my);
    }
    double r = d1*d1 / (d2 * d3);
    if (r >= 0.7) {
        NSMutableArray *newValueX = [NSMutableArray array];
        NSMutableArray *newValueY = [NSMutableArray array];
        if (newArray.count == 0) {
            return 0;
        }
        for (NSDictionary *dict in newArray){
            [newValueX addObject:dict[@"x"]];
            [newValueY addObject:dict[@"y"]];
        }
        //标准偏差
        double *yy=(double*)malloc(sizeof(double)*n);
        double sumerrorsquare=0,z;
        for(i=0;i<newArray.count;i++) {
            /* 根据模型计算出的值 */
            yy[i]=a * [newValueX[i] floatValue] + b;
            //  printf("%f ",yy[i]);
            /*计算值与实际值之差*/
            z = yy[i]-[newValueY[i] floatValue];
            sumerrorsquare+= z*z;
        }
        result=sqrt(sumerrorsquare/(n-1)); //总体偏差
    } else{
        NSMutableArray *averArray = [[NSMutableArray alloc] init];
        NSMutableArray *averNewArray = [[NSMutableArray alloc] init];
        for (int i = 0; i<n; i++) {
           double v =  [dataY[i] doubleValue] / [dataX[i] doubleValue];
            [averArray addObject:@(v)];
        }
        for (NSDictionary *dict in newArray) {
            double v = [dict[@"y"] doubleValue] /[dict[@"x"] doubleValue];
            [averNewArray addObject:@(v)];
        }
        
        double average = 0;
        for (NSNumber *value in averNewArray) {
            average += [value doubleValue] / averNewArray.count;
        }
       result = [[DAAverageCalculate defaultInstance] probabilityCalculate:averArray newValue:average];
        
    }
    return result;
}


@end
