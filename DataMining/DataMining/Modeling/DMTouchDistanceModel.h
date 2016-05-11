//
//  DMTouchDistanceModel.h
//  DataMining
//
//  Created by weiguang on 16/5/9.
//  Copyright © 2016年 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMTouchDistanceModel : NSObject

+ (DMTouchDistanceModel *)defaultInstance;

- (double)getProbability :(NSArray *) newValue;

@end

