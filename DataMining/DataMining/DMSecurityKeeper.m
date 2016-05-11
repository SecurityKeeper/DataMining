//
//  DMSecurityKeeper.m
//  DataMining
//
//  Created by Jiao Liu on 5/11/16.
//  Copyright © 2016 SecurityKeeper. All rights reserved.
//

#import "DMSecurityKeeper.h"

@implementation DMSecurityKeeper

static DMSecurityKeeper *keeper = nil;

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keeper = [[DMSecurityKeeper alloc] init];
    });
    return keeper;
}

+ (void)destroyInstance
{
    keeper = nil;
}



@end
