//
//  Location.h
//  locationManager
//
//  Created by 郑红 on 1/19/16.
//  Copyright © 2016 zhenghong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Location : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+ (NSString *)insertLocationWithId:(NSString *)locationId
                      locationInfo:(NSDictionary *)info
                  inManagedCobtext:(NSManagedObjectContext *)context;


+ (NSFetchedResultsController *)fetchLocationInfo:(NSManagedObjectContext * )context;

+ (NSArray *)fetchAllInfo:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "Location+CoreDataProperties.h"
