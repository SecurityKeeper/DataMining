//
//  DeviceMotion.m
//  DataMining
//
//  Created by liuxu on 16/1/22.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import "DeviceMotion.h"


@implementation DeviceMotion

@dynamic date;
@dynamic pitch;
@dynamic roll;
@dynamic yaw;

- (void)setDataWithDict:(NSDictionary*)dict {
    self.date     = [dict objectForKey:@"date"];
    self.pitch    = [dict objectForKey:@"pitch"];
    self.roll     = [dict objectForKey:@"roll"];
    self.yaw      = [dict objectForKey:@"yaw"];
}

- (NSDictionary*)getDictionary {
    NSDictionary* dict = @{@"date":self.date,
                           @"pitch":self.pitch,
                           @"roll":self.roll,
                           @"yaw":self.yaw};
    
    return dict;
}

@end
