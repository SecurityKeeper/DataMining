//
//  DAAverageCalculate.h
//  DataAnalysis
//
//  Created by 郑红 on 3/30/16.
//  Copyright © 2016 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DAAverageCalculate : NSObject

+ (DAAverageCalculate *)defaultInstance;
- (long double)probabilityCalculate:(NSArray *)array newValue:(long double) newValue;
@end