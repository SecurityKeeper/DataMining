//
//  DeviceMotion.m
//  DataMining
//
//  Created by liuxu on 16/1/22.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import "DeviceMotion.h"
#import "CollectorDef.h"

@implementation DeviceMotion

@dynamic pitch;
@dynamic roll;
@dynamic yaw;
@dynamic timesTamp;

- (void)setDataWithDict:(NSDictionary*)dict {
    self.pitch     = [dict objectForKey:kPitch];
    self.roll      = [dict objectForKey:kRoll];
    self.yaw       = [dict objectForKey:kYaw];
    self.timesTamp = [dict objectForKey:kTimesTamp];
}

- (NSDictionary*)getDictionary {
    NSDictionary* dict = @{kPitch:self.pitch,
                           kRoll:self.roll,
                           kYaw:self.yaw,
                           kTimesTamp:self.timesTamp};
    
    return dict;
}

@end
