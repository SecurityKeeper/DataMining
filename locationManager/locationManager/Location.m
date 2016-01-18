//
//  Location.m
//  locationManager
//
//  Created by 郑红 on 1/14/16.
//  Copyright © 2016 zhenghong. All rights reserved.
//

#import "Location.h"

@implementation Location

+ (NSString *)insertLocationWithId:(NSString *)locationId
                        locationInfo:(NSDictionary *)info
                    inManagedCobtext:(NSManagedObjectContext *)context {
    Location * location = [NSEntityDescription insertNewObjectForEntityForName:@"Location"inManagedObjectContext:context];
    location.locationTime = info[@"locationTime"];
    location.longitude    = info[@"longitude"];
    location.latitude     = info[@"latitude"];
    location.province     = info[@"province"];
    location.city         = info[@"city"];
    location.district     = info[@"district"];
    location.street       = info[@"street"];
    location.postalCode   = info[@"postalCode"];
    location.locationID   = info[@"locationID"];
    NSError * error;
    if (![context save:&error]) {
        return [error localizedDescription];
    }
    return @"success";
}

+ (NSFetchedResultsController *)fetchLocationInfo:(NSManagedObjectContext *)context {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    request.predicate = [NSPredicate predicateWithFormat:@"province like %@",@"sichuan"];    
    return  [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
}

+ (NSArray *)fetchAllInfo:(NSManagedObjectContext *)context {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    request.predicate = [NSPredicate predicateWithFormat:@"province like %@",@"sichuan"];
    NSArray * objects = [context executeFetchRequest:request error:nil];
    return objects;
}



// Insert code here to add functionality to your managed object subclass

@end
