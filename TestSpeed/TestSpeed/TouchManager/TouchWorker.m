//
//  TouchWorker.m
//  TestSpeed
//
//  Created by liuxu on 16/1/13.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchWorker.h"

@interface TouchWorker()

@property (nonatomic, copy)touchPointBegin touchBegin;
@property (nonatomic, copy)touchPointEnd touchEnd;

@end

@implementation TouchWorker

+ (TouchWorker*)shareInstance {
    static TouchWorker* worker = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        worker = [[TouchWorker alloc]init];
    });
    
    return worker;
}

- (void)startWork:(touchPointBegin)touchBegin
         touchEnd:(touchPointEnd)touchEnd {
    self.touchBegin = touchBegin;
    self.touchEnd = touchEnd;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onScreenTouch:) name:@"notiScreenTouchBegin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onScreenTouchEnd:) name:@"notiScreenTouchEnd" object:nil];
}

- (void)stopWork {
    [[NSNotificationCenter description]removeObserver:self forKeyPath:@"notiScreenTouchBegin"];
    [[NSNotificationCenter description]removeObserver:self forKeyPath:@"notiScreenTouchEnd"];
}

- (void)onScreenTouch:(NSNotification *)notification {
    UIEvent *event = [notification.userInfo objectForKey:@"data"];
    CGPoint pt = [[[[event allTouches] allObjects] objectAtIndex:0] locationInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    if (_touchBegin) {
        self.touchBegin(pt);
    }
}

- (void)onScreenTouchEnd:(NSNotification *)notification {
    UIEvent *event = [notification.userInfo objectForKey:@"data"];
    CGPoint pt = [[[[event allTouches] allObjects] objectAtIndex:0] locationInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    if (_touchEnd) {
        self.touchEnd(pt);
    }
}

@end
