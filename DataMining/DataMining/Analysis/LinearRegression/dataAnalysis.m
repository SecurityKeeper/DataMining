//
//  dataAnalysis.m
//  signLiner
//
//  Created by weiguang on 16/1/15.
//  Copyright (c) 2016年 weiguang. All rights reserved.
//

#import "dataAnalysis.h"
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

- (double)analysis:(NSMutableArray *)data :(NSMutableArray *)data2{
    
    double x[data.count],  y[data.count];
    int i, n = (int)data.count;
    double sumx,sumy,sumxx,sumyy,sumxy,mx,my,mxx,myy,mxy;
    double a, b;
    // 变量的初始化
    sumx=sumy=sumxx=sumyy=sumxy=0.0;
    
     // 计算data、data2的平均值
    for (i = 0; i<data.count; i++) {
        
        sumx += [[data objectAtIndex:i] floatValue];
        sumy += [[data2 objectAtIndex:i] floatValue];
        
        x[i]= [[data objectAtIndex:i] floatValue];
        y[i] = [[data2 objectAtIndex:i] floatValue];
    }
    mx = sumx / n; //x平均值
    my = sumy / n; //y平均值
   // printf("mx=%f my=%f\n",mx,my);
    
    // 计算x、y平和x*y的平均值
    for(i = 0;i<n;i++){
        
        sumxx += [[data objectAtIndex:i] floatValue] * [[data objectAtIndex:i] floatValue];  //x平方和
        sumyy += [[data2 objectAtIndex:i] floatValue] * [[data2 objectAtIndex:i] floatValue];//y平方和
        sumxy += [[data objectAtIndex:i] floatValue] * [[data2 objectAtIndex:i] floatValue]; //x*y求和
    
    }
    mxx = sumxx / n;
    myy = sumyy / n;
    mxy = sumxy / n;
   // printf("mxx=%f myy=%f mxy=%f\n",mxx,myy,mxy);
   //计算系数
    a=(n*sumxy-sumx*sumy)/(n*sumxx-sumx*sumx);
    b=(sumxx*sumy-sumx*sumxy)/(n*sumxx-sumx*sumx);
   // b= my - _a*mx;
    printf("a=%f b=%f\n",a,b);
    //标准偏差
    double *yy=(double*)malloc(sizeof(double)*n);
    double sumerrorsquare=0,error,z;
    for(i=0;i<n;i++) {
        yy[i]=a*[[data objectAtIndex:i] floatValue] + b;
        //  printf("%f ",yy[i]);  /* 根据模型计算出的值 */
        
        z = yy[i]-[[data2 objectAtIndex:i] floatValue];   /*计算值与实际值之差*/
        
        sumerrorsquare+= z*z;//
        
        //  printf("z[%d] = %lf\n",i,z);
    }
    error=sqrt(sumerrorsquare/(n-1));//总体偏差
    // printf("总体偏差s(y)=%f\n",error);
    return error;
    
}

- (BOOL)getIsTrue:(NSMutableArray *)data :(NSMutableArray *)data2{
    int i, n = (int)data.count;
    double d1, d2, d3;
    double sumx,sumy,mx,my;
    // 变量的初始化
    d1 = d2 = d3 =sumx=sumy=0.0;
    
    // 计算data、data2的平均值
    for (i = 0; i<data.count; i++) {
        
        sumx += [[data objectAtIndex:i] floatValue];
        sumy += [[data2 objectAtIndex:i] floatValue];
    }
    mx = sumx / n; //x平均值
    my = sumy / n; //y平均值
    // 计算相关系数的数据组成部分,相关系数决定回归方程估测可靠程度的高低
    for (i = 0; i < n; i++) {
        d1 += ([[data objectAtIndex:i] floatValue] - mx) * ([[data2 objectAtIndex:i] floatValue] - my);
        d2 += ([[data objectAtIndex:i] floatValue] - mx) * ([[data objectAtIndex:i] floatValue] - mx);
        d3 += ([[data2 objectAtIndex:i] floatValue] - my) * ([[data2 objectAtIndex:i] floatValue] - my);
    }
    double r = d1*d1 / (d2 * d3);
    if (r >= 0.7) {
        return YES;
        
    }else{
        return NO;
    }
}

@end
