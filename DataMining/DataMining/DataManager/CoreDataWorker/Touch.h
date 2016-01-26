//
//  Touch.h
//  DataMining
//
//  Created by liuxu on 16/1/22.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Touch : NSManagedObject

@property (nonatomic, retain) NSNumber * timesTamp;
@property (nonatomic, retain) NSNumber * touchType;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;

- (void)setDataWithDict:(NSDictionary*)dict;
- (NSDictionary*)getDictionary;

@end
