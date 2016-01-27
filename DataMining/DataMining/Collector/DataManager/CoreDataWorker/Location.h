//
//  Location.h
//  DataMining
//
//  Created by liuxu on 16/1/22.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * timesTamp;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * adCode;

- (void)setDataWithDict:(NSDictionary*)dict;
- (NSDictionary*)getDictionary;

@end
