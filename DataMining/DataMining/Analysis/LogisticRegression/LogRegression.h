//
//  LogRegression.h
//  DataAnalysis
//
//  Created by dengjc on 16/1/15.
//  Copyright (c) 2016年 dengjc. All rights reserved.
//
#ifndef __DataAnalysis__LogRegression__
#define __DataAnalysis__LogRegression__

NSArray *loadDataFromFile();

float sigmoid(float x);

float pi(float x,int k);//泊松分布

/**
 arrIn为数据库数据，numIter为迭代次数.
 weights为模型系数（由gradientAscent返回）
 likelyHoodRatioCheck返回true表示模型可信
 checkData返回新数据可信的概率
 
 步骤：
 1、再调用likelyHoodRatioCheck检验模型，模型可信继续第2步，否则返回
 2、调用checkData检验新数据
 
 arrIn格式：
 NSArray *data1 = @[@[X,Y,L],@[]...;
 X Y 为某一维的值
 L为分类结果，只能为0或1
 */

//NSArray* gradientAscent(NSArray *arrIn,int numIter);

bool likelyHoodRatioCheck(NSArray *arrIn);

float checkData(NSArray* data);
#endif /* defined(__DataAnalysis__LogRegression__) */