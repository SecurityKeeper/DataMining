//
//  Touch.m
//  DataMining
//
//  Created by liuxu on 16/1/22.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import "Touch.h"
#import "CollectorDef.h"

@implementation Touch

@dynamic touchType;
@dynamic x;
@dynamic y;
@dynamic timesTamp;

- (void)setDataWithDict:(NSDictionary*)dict {
    self.x         = [dict objectForKey:kX];
    self.y         = [dict objectForKey:kY];
    self.touchType = [dict objectForKey:kTouchType];
    self.timesTamp = [dict objectForKey:kTimesTamp];
}

- (NSDictionary*)getDictionary {
    NSDictionary* dict = @{kX:self.x,
                           kY:self.y,
                           kTouchType:self.touchType,
                           kTimesTamp:self.timesTamp};
    return dict;
}

@end
