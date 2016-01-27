//
//  DeviceMotion.h
//  DataMining
//
//  Created by liuxu on 16/1/22.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DeviceMotion : NSManagedObject

@property (nonatomic, retain) NSNumber* timesTamp;
@property (nonatomic, retain) NSNumber * pitch;
@property (nonatomic, retain) NSNumber * roll;
@property (nonatomic, retain) NSNumber * yaw;

- (void)setDataWithDict:(NSDictionary*)dict;
- (NSDictionary*)getDictionary;

@end
