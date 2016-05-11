//
//  DMSecurityKeeper.h
//  DataMining
//
//  Created by Jiao Liu on 5/11/16.
//  Copyright © 2016 SecurityKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DMSecurityKeeper : NSObject<UIAlertViewDelegate>
{
    @private
    NSMutableDictionary *analysisOut;
    UIAlertView *loginAlert;
}

@property (nonatomic,assign,readonly) BOOL isValid;

/**
 Instance Methods
 */
+ (id)sharedInstance;
+ (void)destroyInstance;

- (void)startKeeper;

@end
