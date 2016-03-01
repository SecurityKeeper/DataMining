//
//  LinearRegression.h
//  DataAnalysis
//
//  Created by weiguang on 16/1/20.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>
#define N 3
void regAnalysis(double *x,double *y,int m,int n,double *a,double *dt,double *v);
void setData(NSMutableArray *dataX,NSMutableArray *dataY);
//double getA(double arcs[N][N],int n);
//void getAStart(double arcs[N][N],int n,double ans[N][N]);
int DinV(double A[N][N],int n);
