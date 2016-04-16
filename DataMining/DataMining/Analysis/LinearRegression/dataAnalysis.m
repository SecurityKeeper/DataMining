//
//  dataAnalysis.m
//  signLiner
//
//  Created by weiguang on 16/1/15.
//  Copyright (c) 2016年 weiguang. All rights reserved.
//

#import "dataAnalysis.h"
#import "DataStorageManager.h"
#import "CollectDataManager.h"
#import "DMTouchTimeModel.h"

@implementation dataAnalysis

+ (dataAnalysis *)defaultInstance {
    static dispatch_once_t token;
    static dataAnalysis * model = nil;
    dispatch_once(&token, ^{
        model = [[dataAnalysis alloc] init];
    });
    return model;
}
double a,b;
NSMutableArray *dataX;
NSMutableArray *dataY;

/** 加载数据 */
- (void) loadData {
    
    dataX = [[NSMutableArray alloc] init];
    dataY = [[NSMutableArray alloc] init];
    NSMutableArray *dataBeginX = [[NSMutableArray alloc] init];
    NSMutableArray *dataBeginY = [[NSMutableArray alloc] init];
    NSMutableArray *dataEndX = [[NSMutableArray alloc] init];
    NSMutableArray *dataEndY = [[NSMutableArray alloc] init];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    NSMutableArray *data2 = [[NSMutableArray alloc] init];
    //dataSrcType_tempStorage  dataSrcType_reliableStorage
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
    dataY = data;
    dataX = timeArray;
    
   // NSLog(@"########%@",tempArray);

}


- (double) analysis :(NSMutableArray *)data and:(NSMutableArray *)data2{
    
    [self loadData];
    data2 = dataY;
    data = dataX;
    double x[data.count],  y[data2.count];
    int i, n = (int)data.count;
    double d1, d2, d3;
    double sumx,sumy,sumxx,sumyy,sumxy,mx,my,mxx,myy,mxy;
    // 变量的初始化
    d1 = d2 = d3 =sumx=sumy=sumxx=sumyy=sumxy=0.0;
    
     // 计算data、data2的平均值
    for (i = 0; i<data.count; i++) {
        
        sumx += [[data objectAtIndex:i] floatValue];
        sumy += [[data2 objectAtIndex:i] floatValue];
        
        x[i]= [[data objectAtIndex:i] floatValue];
        y[i] = [[data2 objectAtIndex:i] floatValue];
    }
    mx = sumx / n; //x平均值
    my = sumy / n; //y平均值
    
    // 计算x、y平和x*y的平均值
    for(i = 0;i<n;i++){
        
        sumxx += [[data objectAtIndex:i] floatValue] * [[data objectAtIndex:i] floatValue];  //x平方和
        sumyy += [[data2 objectAtIndex:i] floatValue] * [[data2 objectAtIndex:i] floatValue];//y平方和
        sumxy += [[data objectAtIndex:i] floatValue] * [[data2 objectAtIndex:i] floatValue]; //x*y求和
    
    }
    mxx = sumxx / n;
    myy = sumyy / n;
    mxy = sumxy / n;
    
    a=(n*sumxy-sumx*sumy)/(n*sumxx-sumx*sumx);
    b=(sumxx*sumy-sumx*sumxy)/(n*sumxx-sumx*sumx);

    //标准偏差
    double *yy=(double*)malloc(sizeof(double)*n);
    double sumerrorsquare=0,error,z;
    for(i=0;i<n;i++) {
        yy[i]=a*[[data objectAtIndex:i] floatValue]+b;
        //  printf("%f ",yy[i]);  /* 计算实际求出的值 */
        
        z = yy[i]-[[data2 objectAtIndex:i] floatValue];   /*计算值与实际值之差*/
        
        sumerrorsquare+= z*z;//
        
        //  printf("z[%d] = %lf\n",i,z);
    }
    error=sqrt(sumerrorsquare/(n-1));//总体偏差
    // printf("标准偏差s(y)=%f\n",error);

    // 计算相关系数的数据组成部分,相关系数决定回归方程估测可靠程度的高低
    for (i = 0; i < n; i++) {
        d1 += ([[data objectAtIndex:i] floatValue] - mx) * ([[data2 objectAtIndex:i] floatValue] - my);
        d2 += ([[data objectAtIndex:i] floatValue] - mx) * ([[data objectAtIndex:i] floatValue] - mx);
        d3 += ([[data2 objectAtIndex:i] floatValue] - my) * ([[data2 objectAtIndex:i] floatValue] - my);
    }
    
    double r = d1 / sqrt(d2 * d3);
   // printf("相关系数r=%f\n",r);
    return r;
}

@end
