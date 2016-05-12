//
//  DMSecurityKeeper.m
//  DataMining
//
//  Created by Jiao Liu on 5/11/16.
//  Copyright © 2016 SecurityKeeper. All rights reserved.
//

#import "DMSecurityKeeper.h"
#import "CollectDataManager.h"
#import "DataStorageManager.h"
#import "DMAnalysisModel.h"

@implementation DMSecurityKeeper

@synthesize isValid;

static DMSecurityKeeper *keeper = nil;
NSString *password = @"123";

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keeper = [[DMSecurityKeeper alloc] init];
    });
    return keeper;
}

+ (void)destroyInstance
{
    keeper = nil;
}

- (void)startKeeper
{
    NSArray *tempTouch = [[DataStorageManager shareInstance] getDataType:entitiesType_Touch WithCount:0 dataFrom:dataSrcType_reliableStorage];
    if (tempTouch == 0) {
        loginAlert = [[UIAlertView alloc] initWithTitle:@"请登录" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        loginAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [loginAlert textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
        [loginAlert show];
    }
    else
    {
        [[CollectDataManager shareInstance] startWork];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [[CollectDataManager shareInstance] stopWork];
//            sleep(1);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                analysisOut = [[DMAnalysisModel sharedInstance] startAnalysis];
                if ([[analysisOut objectForKey:kAnalysisOut] boolValue]) {
                    isValid = true;
                    [[DataStorageManager shareInstance] saveType:entitiesType_AnalysisData WithData:analysisOut storage:dataSrcType_reliableStorage];
                    //                sleep(1);
                    //                [[CollectDataManager shareInstance] startWork];
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        loginAlert = [[UIAlertView alloc] initWithTitle:@"请登录" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                        loginAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                        [loginAlert textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
                        [loginAlert show];
                    });
                }
            });
        });
    }
}

#pragma mark - Alert Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[CollectDataManager shareInstance] stopWork];
        [[DataStorageManager shareInstance] removeAllTempStorageData];
        [[DataStorageManager shareInstance] removeMemoryData];
        isValid = false;
        if (analysisOut != nil) {
            [[DataStorageManager shareInstance] saveType:entitiesType_AnalysisData WithData:analysisOut storage:dataSrcType_reliableStorage];
        }
    }
    else
    {
        if ([[[alertView textFieldAtIndex:0] text] isEqualToString:password]) {
            isValid = true;
            if (analysisOut != nil) {
                [analysisOut setObject:[NSNumber numberWithBool:true] forKey:kAnalysisOut];
                [[DataStorageManager shareInstance] saveType:entitiesType_AnalysisData WithData:analysisOut storage:dataSrcType_reliableStorage];
            }
//            sleep(1);
//            [[CollectDataManager shareInstance] startWork];
        }
        else
        {
            isValid = false;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [loginAlert textFieldAtIndex:0].text = @"";
                [loginAlert show];
            });
        }
    }
}

@end
