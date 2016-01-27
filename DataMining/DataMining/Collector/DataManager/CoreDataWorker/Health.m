//
//  Health.m
//  DataMining
//
//  Created by liuxu on 16/1/22.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import "Health.h"


@implementation Health

@dynamic distance;
@dynamic stepCount;
@dynamic timesTamp;

- (void)setDataWithDict:(NSDictionary*)dict {
    self.distance     = [dict objectForKey:@"distance"];
    self.stepCount    = [dict objectForKey:@"stepCount"];
    self.timesTamp    = [dict objectForKey:@"timesTamp"];
}

- (NSDictionary*)getDictionary {
    NSDictionary* dict = @{@"distance":self.distance,
                           @"stepCount":self.stepCount,
                           @"timesTamp":self.timesTamp};
    return dict;
}

@end
