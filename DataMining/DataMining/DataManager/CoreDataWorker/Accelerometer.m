//
//  Accelerometer.m
//  DataMining
//
//  Created by liuxu on 16/1/22.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import "Accelerometer.h"


@implementation Accelerometer

@dynamic date;
@dynamic x;
@dynamic y;
@dynamic z;
@dynamic timesTamp;

- (void)setDataWithDict:(NSDictionary*)dict {
    self.date  = [dict objectForKey:@"date"];
    self.x     = [dict objectForKey:@"x"];
    self.y     = [dict objectForKey:@"y"];
    self.z     = [dict objectForKey:@"z"];
    self.timesTamp = [dict objectForKey:@"timesTamp"];
}

- (NSDictionary*)getDictionary {
    NSDictionary* dict = @{@"date":self.date,
                           @"x":self.x,
                           @"y":self.y,
                           @"z":self.z,
                           @"timesTamp":self.timesTamp};
    return dict;
}

@end
