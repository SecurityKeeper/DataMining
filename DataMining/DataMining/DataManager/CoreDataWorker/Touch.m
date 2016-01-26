//
//  Touch.m
//  DataMining
//
//  Created by liuxu on 16/1/22.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import "Touch.h"


@implementation Touch

@dynamic date;
@dynamic touchType;
@dynamic x;
@dynamic y;
@dynamic timesTamp;

- (void)setDataWithDict:(NSDictionary*)dict {
    self.date      = [dict objectForKey:@"date"];
    self.x         = [dict objectForKey:@"x"];
    self.y         = [dict objectForKey:@"y"];
    self.touchType = [dict objectForKey:@"touchType"];
    self.timesTamp = [dict objectForKey:@"timesTamp"];
}

- (NSDictionary*)getDictionary {
    NSDictionary* dict = @{@"date":self.date,
                           @"x":self.x,
                           @"y":self.y,
                           @"touchType":self.touchType,
                           @"timesTamp":self.timesTamp};
    return dict;
}

@end
