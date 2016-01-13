/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    Abstract:Contains shared helper methods on HKHealthStore that are specific to Fit's use cases.
*/

#import "HKHealthStore+AAPLExtensions.h"

@implementation HKHealthStore (AAPLExtensions)

- (void)aapl_mostRecentQuantitySampleOfType:(HKQuantityType *)quantityType predicate:(NSPredicate *)predicate completion:(void (^)(NSArray *, NSError *))completion {
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:quantityType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        if (completion) {
//          NSLog(@"健康获取数据 ---- > = %@",results);
            completion(results, error);
        }
    }];
    
    [self executeQuery:query];
}

@end
