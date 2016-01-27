//
//  Accelerometer.m
//  DataMining
//
//  Created by liuxu on 16/1/22.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import "Accelerometer.h"
#import "CollectorDef.h"

@implementation Accelerometer

@dynamic x;
@dynamic y;
@dynamic z;
@dynamic timesTamp;

- (void)setDataWithDict:(NSDictionary*)dict {
    self.x     = [dict objectForKey:kX];
    self.y     = [dict objectForKey:kY];
    self.z     = [dict objectForKey:kZ];
    self.timesTamp = [dict objectForKey:kTimesTamp];
}

- (NSDictionary*)getDictionary {
    NSDictionary* dict = @{kX:self.x,
                           kY:self.y,
                           kZ:self.z,
                           kTimesTamp:self.timesTamp};
    return dict;
}

@end
