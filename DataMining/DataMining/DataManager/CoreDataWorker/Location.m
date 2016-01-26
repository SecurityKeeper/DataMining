//
//  Location.m
//  DataMining
//
//  Created by liuxu on 16/1/22.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import "Location.h"


@implementation Location

@dynamic date;
@dynamic latitude;
@dynamic longitude;
@dynamic adCode;
@dynamic timesTamp;

- (void)setDataWithDict:(NSDictionary*)dict {
    self.date      = [dict objectForKey:@"date"];
    self.latitude  = [dict objectForKey:@"latitude"];
    self.longitude = [dict objectForKey:@"longitude"];
    self.adCode    = [dict objectForKey:@"adCode"];
    self.timesTamp = [dict objectForKey:@"timesTamp"];
}

- (NSDictionary*)getDictionary {
    NSDictionary* dict = @{@"date":self.date,
                           @"latitude":self.latitude,
                           @"longitude":self.longitude,
                           @"adCode":self.adCode,
                           @"timesTamp":self.timesTamp};
    return dict;
}

@end
