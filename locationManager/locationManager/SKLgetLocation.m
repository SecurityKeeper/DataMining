//
//  SKLgetLocation.m
//  locationManager
//
//  Created by 郑红 on 1/14/16.
//  Copyright © 2016 zhenghong. All rights reserved.
//

#import "SKLgetLocation.h"
@interface SKLgetLocation ()<CLLocationManagerDelegate>
{
    
}

@property (nonatomic,strong) CLLocationManager * locationManager;
@property (nonatomic,strong) CLGeocoder * geocoder;
@property (nonatomic,assign) double distanceFilter;
@property (nonatomic,assign) CLLocationAccuracy accurcy;

@end

@implementation SKLgetLocation

- (instancetype)init {
    self.distanceFilter = 1.0;
    self.accurcy = kCLLocationAccuracyNearestTenMeters;
    return [self initWithDistanceFilter:_distanceFilter desireAccuracy:_accurcy];
}

- (instancetype)initWithDistanceFilter:(double)distance
                        desireAccuracy:(CLLocationAccuracy)accuracy {
    self = [super init];
    if (self) {
        [self initLocationManager];
    }
    return self;
}

- (void)dealloc {
    self.locationManager = nil;
    self.geocoder = nil;
}

- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    return _locationManager;
}

- (CLGeocoder *)geocoder {
    if (_geocoder == nil) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (void)initLocationManager {
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager.distanceFilter = self.distanceFilter;
        self.locationManager.desiredAccuracy = self.accurcy;
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager startUpdatingLocation];
    } else {
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation * location = [locations firstObject];
    CLLocationCoordinate2D  coordinate = location.coordinate;
    
    NSString * des = location.description;
    NSLog(@"ooop::%@",des);
    
    CLFloor *floor = location.floor;
    NSInteger level = floor.level;
    NSLog(@"%ld",(long)level);
    NSDate * date = location.timestamp;
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * strdate = [formatter stringFromDate:date];
    NSLog(@"%@",strdate);
    [self.locationManager stopUpdatingLocation];
    NSLog(@"%f--%f",coordinate.longitude,coordinate.latitude);
    
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }
        CLPlacemark * mark = [placemarks firstObject];
        NSLog(@"%@",mark.name);
        
    }];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@",[error localizedDescription]);
}
@end
