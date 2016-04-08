//
//  AnalysisData.h
//  
//
//  Created by Jiao Liu on 4/8/16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AnalysisData : NSManagedObject

@property (nonatomic, retain) NSNumber * analysisOut;
@property (nonatomic, retain) NSNumber * angle;
@property (nonatomic, retain) NSNumber * euler;
@property (nonatomic, retain) NSNumber * place;
@property (nonatomic, retain) NSNumber * stepLength;
@property (nonatomic, retain) NSNumber * timesTamp;
@property (nonatomic, retain) NSNumber * touchForce;
@property (nonatomic, retain) NSNumber * touchMove;

- (void)setDataWithDict:(NSDictionary*)dict;
- (NSDictionary*)getDictionary;

@end
