//
//  DMAverageCalculate.h
//  DataMining
//
//  Created by 郑红 on 2/1/16.
//  Copyright © 2016 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectorDef.h"


@interface DMAverageCalculate : NSObject

+ (DMAverageCalculate *)defaultInstance;
- (long double)probabilityCalculate:(NSArray *)array newValue:(long double) newValue;
@end
