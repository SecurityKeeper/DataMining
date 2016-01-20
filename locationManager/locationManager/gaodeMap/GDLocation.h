//
//  GDLocation.h
//  locationManager
//
//  Created by 郑红 on 1/19/16.
//  Copyright © 2016 zhenghong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GDLocation : NSObject

+ (GDLocation *)defaultLocation;

- (void)startUpdateLocation;
- (void)stopUpdateLocation;
@end
