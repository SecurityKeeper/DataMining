//
//  AnalysisData+CoreDataProperties.h
//  DataMining
//
//  Created by Jiao Liu on 5/12/16.
//  Copyright © 2016 SecurityKeeper. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "AnalysisData.h"

NS_ASSUME_NONNULL_BEGIN

@interface AnalysisData (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *analysisOut;
@property (nullable, nonatomic, retain) NSNumber *angle;
@property (nullable, nonatomic, retain) NSNumber *euler;
@property (nullable, nonatomic, retain) NSNumber *place;
@property (nullable, nonatomic, retain) NSNumber *stepLength;
@property (nullable, nonatomic, retain) NSNumber *timesTamp;
@property (nullable, nonatomic, retain) NSNumber *touchForce;
@property (nullable, nonatomic, retain) NSNumber *touchMove;

@end

NS_ASSUME_NONNULL_END
