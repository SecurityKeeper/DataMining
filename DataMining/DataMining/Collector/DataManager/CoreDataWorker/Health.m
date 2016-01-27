//
//  Health.m
//  DataMining
//
//  Created by liuxu on 16/1/22.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import "Health.h"
#import "CollectorDef.h"

@implementation Health

@dynamic distance;
@dynamic stepCount;
@dynamic timesTamp;

- (void)setDataWithDict:(NSDictionary*)dict {
    self.distance     = [dict objectForKey:kDistance];
    self.stepCount    = [dict objectForKey:kStepCount];
    self.timesTamp    = [dict objectForKey:kTimesTamp];
}

- (NSDictionary*)getDictionary {
    NSDictionary* dict = @{kDistance:self.distance,
                           kStepCount:self.stepCount,
                           kTimesTamp:self.timesTamp};
    return dict;
}

@end
