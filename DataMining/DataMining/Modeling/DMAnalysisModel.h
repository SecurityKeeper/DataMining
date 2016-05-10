//
//  DMAnalysisModel.h
//  DataMining
//
//  Created by Jiao Liu on 5/10/16.
//  Copyright © 2016 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMAnalysisModel : NSObject

/**
 Instance Methods
 */
+ (id)sharedInstance;
+ (void)destroyInstance;

/**
 @abstract calculate all the factors
 @return the determination
 sample {@"analysisOut" : true,
         @"angle" : @"0.5"
         ...
        }
 */

- (NSMutableDictionary *)startAnalysis;

@end
