//
//  ViewController.m
//  TestSpeed
//
//  Created by liuxu on 16/1/8.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import "ViewController.h"
#import "CollectDataManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)startBtnClicked:(id)sender {
    [[CollectDataManager shareInstance]startWork];
}

- (IBAction)stopBtnClicked:(id)sender {
    [[CollectDataManager shareInstance]stopWork];
}

@end
