//
//  dataAnalysis.m
//  signLiner
//
//  Created by weiguang on 16/1/15.
//  Copyright (c) 2016年 weiguang. All rights reserved.
//

#import "dataAnalysis.h"
@interface dataAnalysis()

@property (nonatomic,assign) double a;
@property (nonatomic,assign) double b;

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
    
    _a=(n*sumxy-sumx*sumy)/(n*sumxx-sumx*sumx);
    _b=(sumxx*sumy-sumx*sumxy)/(n*sumxx-sumx*sumx);
   // b= my - a*mx;
    printf("a=%f b=%f\n",_a,_b);
    
    //标准偏差
    double *yy=(double*)malloc(sizeof(double)*n);
    double sumerrorsquare=0,error,z;
    for(i=0;i<n;i++) {
        yy[i]=_a*[[data objectAtIndex:i] floatValue]+_b;
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
