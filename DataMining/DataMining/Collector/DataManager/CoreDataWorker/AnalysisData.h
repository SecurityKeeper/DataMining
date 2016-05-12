//
//  AnalysisData.h
//  DataMining
//
//  Created by Jiao Liu on 5/12/16.
//  Copyright © 2016 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnalysisData : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
- (void)setDataWithDict:(NSDictionary*)dict;
- (NSDictionary*)getDictionary;

@end

NS_ASSUME_NONNULL_END

#import "AnalysisData+CoreDataProperties.h"
