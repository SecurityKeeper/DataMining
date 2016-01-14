//
//  SKLtransformLocation.h
//  locationManager
//
//  Created by 郑红 on 1/14/16.
//  Copyright © 2016 zhenghong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface SKLtransformLocation : NSObject

+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D )location;
+ (CLLocationCoordinate2D)transformLocationFrom:(CLLocationCoordinate2D)oldLocation;

@end
