//
//  LocationWorker.m
//  DataMining
//
//  Created by 郑红 on 1/20/16.
//  Copyright © 2016 liuxu. All rights reserved.
//

#import "LocationWorker.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface LocationWorker ()<AMapLocationManagerDelegate,AMapSearchDelegate>
{
    double longitude;
    double latitude;
}

@property (nonatomic,strong) AMapLocationManager * locationManager;
@property (nonatomic,strong) AMapLocationReGeocode * geocode;
@property (nonatomic,strong) AMapSearchAPI * searchAddress;
@property (nonatomic,copy)   locationInfo locationInfo;


@end

@implementation LocationWorker

- (AMapLocationManager *)locationManager {
    if (_locationManager == nil) {
        self.locationManager = [[AMapLocationManager alloc] init];
        self.locationManager.delegate = self;
        CLLocationDistance minDistcance = 1.0;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
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

- (void)startUpdateLocation:(locationInfo) locationInfo {
    self.locationInfo = locationInfo;
    [self.locationManager startUpdatingLocation];
}


- (void)stopUpdateLocation {
    [self.locationManager stopUpdatingLocation];
}

+ (LocationWorker *)defaultLocation {
    static dispatch_once_t oneLocation;
    static LocationWorker * locationManager;
    dispatch_once(&oneLocation, ^{
        locationManager = [[LocationWorker alloc] init];
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
    longitude = coordate.longitude;
    latitude = coordate.latitude;
    
    AMapReGeocodeSearchRequest * request = [[AMapReGeocodeSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:coordate.latitude longitude:coordate.longitude];
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
        
//        AMapStreetNumber * door = detail.streetNumber;//street 街道名称 number 门牌号
        NSDictionary * locationInfo = @{
                                        @"describe":describe,
                                        @"province":province,
                                        @"city"    :city,
                                        @"district":district,
                                        @"town"    :town,
                                        @"cityCode":cityCode,
                                        @"adCode"  :adcode,
                                        @"longitude":[NSNumber numberWithDouble:longitude],
                                        @"latitude":[NSNumber numberWithDouble:latitude]
                                        };
        
        if (self.locationInfo) {
            self.locationInfo(locationInfo);
        }
    }
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    NSLog(@"error=%@",error);
}


@end
