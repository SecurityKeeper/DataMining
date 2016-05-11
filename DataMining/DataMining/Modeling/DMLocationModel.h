//
//  DMLocationModel.h
//  DataMining
//
//  Created by dengjc on 16/3/30.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataStorageManager.h"
#import "DAClustering.h"


@interface DMLocationModel : NSObject

+ (DMLocationModel *)sharedInstance;
- (double)getWeight:(NSArray*)data;

@end
