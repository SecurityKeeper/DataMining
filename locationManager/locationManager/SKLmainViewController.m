//
//  ViewController.m
//  locationManager
//
//  Created by 郑红 on 1/14/16.
//  Copyright © 2016 zhenghong. All rights reserved.
//

#import "SKLmainViewController.h"
#import "SKLgetLocation.h"

@interface SKLmainViewController ()
{
    SKLgetLocation * location;
}

@end

@implementation SKLmainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    location = [[SKLgetLocation alloc] initWithDistanceFilter:1.0 desireAccuracy:kCLLocationAccuracyNearestTenMeters];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
