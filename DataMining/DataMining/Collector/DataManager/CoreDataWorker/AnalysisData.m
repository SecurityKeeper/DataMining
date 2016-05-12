//
//  AnalysisData.m
//  DataMining
//
//  Created by Jiao Liu on 5/12/16.
//  Copyright © 2016 SecurityKeeper. All rights reserved.
//

#import "AnalysisData.h"
#import "CollectorDef.h"

@implementation AnalysisData

// Insert code here to add functionality to your managed object subclass

- (void)setDataWithDict:(NSDictionary*)dict {
    self.analysisOut     = [dict objectForKey:kAnalysisOut];
    self.angle           = [dict objectForKey:kAngle];
    self.euler           = [dict objectForKey:kEuler];
    self.place           = [dict objectForKey:kPlace];
    self.stepLength      = [dict objectForKey:kStepLength];
    self.touchForce      = [dict objectForKey:kTouchForce];
    self.touchMove       = [dict objectForKey:kTouchMove];
    self.timesTamp       = [dict objectForKey:kTimesTamp];
}

- (NSDictionary*)getDictionary {
    NSDictionary* dict = @{kAnalysisOut:self.analysisOut,
                           kAngle:self.angle,
                           kEuler:self.euler,
                           kPlace:self.place,
                           kStepLength:self.stepLength,
                           kTouchForce:self.touchForce,
                           kTouchMove:self.touchMove,
                           kTimesTamp:self.timesTamp};
    return dict;
}

@end
