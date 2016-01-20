//
//  LocationWorker.h
//  DataMining
//
//  Created by 郑红 on 1/20/16.
//  Copyright © 2016 liuxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocationWorker;
typedef void(^locationInfo)(NSDictionary *);

@interface LocationWorker : NSObject

+ (LocationWorker *)defaultLocation;

- (void)startUpdateLocation:(locationInfo)locationInfo;
- (void)stopUpdateLocation;

@end
