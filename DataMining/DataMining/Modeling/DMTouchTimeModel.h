//
//  DMTouchTimeModel.h
//  DataMining
//
//  Created by 郑红 on 2/18/16.
//  Copyright © 2016 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMTouchTimeModel : NSObject

+ (DMTouchTimeModel *)defaultInstance;

- (long double)getProbability:(double) newValue;
- (NSMutableArray *)getTouchTime;
@end
