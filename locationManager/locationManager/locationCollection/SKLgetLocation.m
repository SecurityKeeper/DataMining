//
//  SKLgetLocation.m
//  locationManager
//
//  Created by 郑红 on 1/19/16.
//  Copyright © 2016 zhenghong. All rights reserved.
//

#import "SKLgetLocation.h"
#import "Location.h"
#import <CoreData/CoreData.h>

@interface SKLgetLocation ()<CLLocationManagerDelegate>
{
    
}
@property (nonatomic,strong) CLLocationManager * locationManager;
@property (nonatomic,strong) CLGeocoder * geocoder;
@property (nonatomic,assign) double distanceFilter;
@property (nonatomic,assign) CLLocationAccuracy accurcy;
@property (nonatomic,strong) NSManagedObjectContext * locationContext;

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
        [self initLocationContext];
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
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager requestAlwaysAuthorization];
         [self.locationManager startUpdatingLocation];

    } else {
        
    }
}

- (void)startUpdateLocation {
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdateLocation {
    [self.locationManager stopUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation * location = [locations firstObject];
    CLLocationCoordinate2D  coordinate = location.coordinate;
    //104.061688--30.544552
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
  
    NSLog(@"%f--%f",coordinate.longitude,coordinate.latitude);
    
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }
        CLPlacemark * mark = [placemarks firstObject];
        NSLog(@"%@",mark.name);
        
        NSDictionary * dic = mark.addressDictionary;
        NSLog(@"%@",dic);
        
    }];
    
    NSDictionary * dic = @{
                           @"locationTime":location.timestamp,
                           @"longitude"   :[NSNumber numberWithDouble:coordinate.longitude],
                           @"latitude"    :[NSNumber numberWithDouble:coordinate.latitude],
                           @"postalCode"  :[NSNumber numberWithInt:123456],
                           @"province"    :@"sichuan",
                           @"city"        :@"chengdu",
                           @"district"    :@"gaoxingqu",
                           @"street"      :@"sijie",
                           @"locationID"  :@"bbbbaaaaccc",
                           };
    
//    NSString * msg = [Location insertLocationWithId:@"bbbbaaaaccc" locationInfo:dic inManagedCobtext:self.locationContext];
//    NSLog(@"%@",msg);
//    
//    NSArray * arr = [Location fetchAllInfo:self.locationContext];
//    NSLog(@"sql:\n%@",arr);
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@",[error localizedDescription]);
}


- (void)initLocationContext {
    NSManagedObjectModel * locationModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    //        NSString * filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    //        NSString * path = [filePath stringByAppendingPathComponent:@"location.db"];
    //        NSURL * url = [NSURL URLWithString:path];
    NSURL* storeURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"test.sqlite"]];
    
    self.locationContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    self.locationContext.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:locationModel];
    
    NSError* error;
    [self.locationContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    
    if (error) {
        NSLog(@"error: %@", error);
    }
    self.locationContext.undoManager = [[NSUndoManager alloc] init];
}

@end
