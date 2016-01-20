//
//  ViewController.m
//  locationManager
//
//  Created by 郑红 on 1/14/16.
//  Copyright © 2016 zhenghong. All rights reserved.
//

#import "SKLmainViewController.h"
#import "SKLgetLocation.h"
#import "GDLocation.h"
@interface SKLmainViewController ()
{
    SKLgetLocation * location;
    GDLocation * gdLocation;
}

@end

@implementation SKLmainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    location = [[SKLgetLocation alloc] initWithDistanceFilter:1.0 desireAccuracy:kCLLocationAccuracyNearestTenMeters];
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    gdLocation = [GDLocation defaultLocation];
    [gdLocation startUpdateLocation];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
