//
//  DPApplication.m
//  TestSpeed
//
//  Created by liuxu on 16/1/13.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPApplication.h"

NSString *const notiScreenTouch = @"notiScreenTouch";

@implementation DPApplication

- (void)sendEvent:(UIEvent *)event {
    if (event.type == UIEventTypeTouches) {
        if ([[event.allTouches anyObject] phase] == UITouchPhaseBegan) {
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:notiScreenTouch object:nil userInfo:[NSDictionary dictionaryWithObject:event forKey:@"data"]]];
        }
    }
    [super sendEvent:event];
}

@end
