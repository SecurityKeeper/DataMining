//
//  Location.m
//  DataMining
//
//  Created by liuxu on 16/1/22.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import "Location.h"
#import "CollectorDef.h"

@implementation Location

@dynamic latitude;
@dynamic longitude;
@dynamic adCode;
@dynamic timesTamp;

- (void)setDataWithDict:(NSDictionary*)dict {
    self.latitude  = [dict objectForKey:kLatitude];
    self.longitude = [dict objectForKey:kLongitude];
    self.adCode    = [dict objectForKey:kAdCode];
    self.timesTamp = [dict objectForKey:kTimesTamp];
}

- (NSDictionary*)getDictionary {
    NSDictionary* dict = @{kLatitude:self.latitude,
                           kLongitude:self.longitude,
                           kAdCode:self.adCode,
                           kTimesTamp:self.timesTamp};
    return dict;
}

@end
