//
//  DPApplication.m
//  TestSpeed
//
//  Created by liuxu on 16/1/13.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPApplication.h"
#import "CollectorDef.h"

@implementation DPApplication

- (void)sendEvent:(UIEvent *)event {
    if (event.type == UIEventTypeTouches) {
        if ([[event.allTouches anyObject] phase] == UITouchPhaseBegan) {
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotiScreenTouchBegin object:nil userInfo:[NSDictionary dictionaryWithObject:event forKey:@"data"]]];
        }
        else if ([[event.allTouches anyObject] phase] == UITouchPhaseEnded) {
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotiScreenTouchEnd object:nil userInfo:[NSDictionary dictionaryWithObject:event forKey:@"data"]]];
        }
        else if ([[event.allTouches anyObject] phase] == UITouchPhaseMoved) {
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotiScreenTouchMove object:nil userInfo:[NSDictionary dictionaryWithObject:event forKey:@"data"]]];
        }
    }
    [super sendEvent:event];
}

@end
