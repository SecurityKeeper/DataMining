//
//  SKLgetLocation.h
//  locationManager
//
//  Created by 郑红 on 1/19/16.
//  Copyright © 2016 zhenghong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface SKLgetLocation : NSObject


- (instancetype)initWithDistanceFilter:(double )distance
                        desireAccuracy:(CLLocationAccuracy)accuracy;
- (void)startUpdateLocation;
- (void)stopUpdateLocation;
@end
