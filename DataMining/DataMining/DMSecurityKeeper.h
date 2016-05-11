//
//  DMSecurityKeeper.h
//  DataMining
//
//  Created by Jiao Liu on 5/11/16.
//  Copyright © 2016 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMSecurityKeeper : NSObject

/**
 Instance Methods
 */
+ (id)sharedInstance;
+ (void)destroyInstance;

@end
