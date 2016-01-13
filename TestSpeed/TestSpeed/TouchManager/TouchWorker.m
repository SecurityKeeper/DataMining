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

@property (nonatomic, copy)touchPoint touch;

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

- (void)startWork:(touchPoint)touch {
    self.touch = touch;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onScreenTouch:) name:@"notiScreenTouch" object:nil];
}

- (void)stopWork {
    [[NSNotificationCenter description]removeObserver:self forKeyPath:@"notiScreenTouch"];
}

- (void)onScreenTouch:(NSNotification *)notification {
    UIEvent *event=[notification.userInfo objectForKey:@"data"];
    CGPoint pt = [[[[event allTouches] allObjects] objectAtIndex:0] locationInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    if (_touch) {
        self.touch(pt);
    }
}

@end
