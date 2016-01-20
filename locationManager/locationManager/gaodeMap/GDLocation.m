//
//  GDLocation.m
//  locationManager
//
//  Created by 郑红 on 1/19/16.
//  Copyright © 2016 zhenghong. All rights reserved.
//

#import "GDLocation.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
@interface GDLocation ()<AMapLocationManagerDelegate,AMapSearchDelegate>
{
    
}

@property (nonatomic,strong) AMapLocationManager * locationManager;
@property (nonatomic,strong) AMapLocationReGeocode * geocode;
@property (nonatomic,strong) AMapSearchAPI * searchAddress;

@end

@implementation GDLocation

- (AMapLocationManager *)locationManager {
    if (_locationManager == nil) {
        self.locationManager = [[AMapLocationManager alloc] init];
        self.locationManager.delegate = self;
        CLLocationDistance minDistcance = 1.0;
        self.locationManager.distanceFilter = minDistcance;
        [self.locationManager setPausesLocationUpdatesAutomatically:NO];
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    return _locationManager;
}

- (AMapSearchAPI *)searchAddress {
    if (_searchAddress == nil) {
        self.searchAddress = [[AMapSearchAPI alloc] init];
        self.searchAddress.delegate = self;
    }
    return _searchAddress;
}
- (void)startUpdateLocation {
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdateLocation {
    [self.locationManager stopUpdatingLocation];
}

+ (GDLocation *)defaultLocation {
    dispatch_once_t oneLocation;
    static GDLocation * locationManager;
    dispatch_once(&oneLocation, ^{
        locationManager = [[GDLocation alloc] init];
    });
    return locationManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error {
    
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location {
    CLLocationCoordinate2D coordate = location.coordinate;
    NSLog(@"%f   %f",coordate.longitude,coordate.latitude);
    AMapReGeocodeSearchRequest * request = [[AMapReGeocodeSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:30.544552 longitude:104.061688];
    request.radius = 1000;
    request.requireExtension = YES;
    
    [self.searchAddress AMapReGoecodeSearch:request];
    
}
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    if (response.regeocode != nil) {
        AMapReGeocode * regeocode = response.regeocode;
        AMapAddressComponent * detail = regeocode.addressComponent;
        NSString * describe = regeocode.formattedAddress;//完成描述
        NSString * province = detail.province;//省
        NSString * city = detail.city;//市
        NSString * district = detail.district;//区
        NSString * town = detail.township;//镇
        NSString * cityCode = detail.citycode;//城市编码
        NSString * adcode = detail.adcode;//区域编码
        
        AMapStreetNumber * door = detail.streetNumber;//street 街道名称 number 门牌号
        
        NSLog(@"oo::%@",describe);
        NSLog(@"%@",detail);
    }
}
@end
