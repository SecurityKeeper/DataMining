//
//  DMAverageCalculate.h
//  DataMining
//
//  Created by 郑红 on 2/1/16.
//  Copyright © 2016 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectorDef.h"

typedef void(^calculate)(long double,long double);
typedef void(^calculateResult)(long double);

@interface DMAverageCalculate : NSObject

- (DMAverageCalculate *)sharedManager;

- (void)calculateType:(entitiesType)numberType Value:(double)value result:(calculateResult)result;

@end
