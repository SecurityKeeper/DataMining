//
//  Health.m
//  DataMining
//
//  Created by liuxu on 16/1/22.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import "Health.h"


@implementation Health

@dynamic date;
@dynamic distance;
@dynamic stepCount;

- (void)setDataWithDict:(NSDictionary*)dict {
    self.date         = [dict objectForKey:@"date"];
    self.distance     = [dict objectForKey:@"distance"];
    self.stepCount    = [dict objectForKey:@"stepCount"];
}

- (NSDictionary*)getDictionary {
    NSDictionary* dict = @{@"date":self.date,
                           @"distance":self.distance,
                           @"stepCount":self.stepCount};
    return dict;
}

@end
