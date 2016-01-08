//
//  ViewController.m
//  TestSpeed
//
//  Created by liuxu on 16/1/8.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h> 

void messageBox(NSString* str) {
    UIAlertView* view = [[UIAlertView alloc]initWithTitle:@"debug" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [view show];
}

@interface ViewController ()

@property (nonatomic,strong) CMMotionManager* motionManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __block NSString* str = nil;
    self.motionManager=[[CMMotionManager alloc]init];
    self.motionManager.gyroUpdateInterval=0.1;
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
        str = [NSString stringWithFormat:@"旋转角度:X:%.3f,Y:%.3f,X:%.3f",gyroData.rotationRate.x,gyroData.rotationRate.y,gyroData.rotationRate.z];
        messageBox(str);
    }];
    
    self.motionManager.accelerometerUpdateInterval=0.1;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        str = [NSString stringWithFormat:@"加速计:X:%.3f,Y:%.3f,Z:%.3f",accelerometerData.acceleration.x,accelerometerData.acceleration.y,accelerometerData.acceleration.z];
        messageBox(str);
    }];
}

- (void)stop {
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopGyroUpdates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
