//
//  ViewController.m
//  DataMining
//
//  Created by liuxu on 16/1/19.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import "ViewController.h"
#import "CollectDataManager.h"
#import "CollectorDef.h"

#import "DAAverageCalculate.h" //test

#import "DMLocationModel.h"

#import "DMAngleModel.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray* dataArray;
    NSArray* mArray;
    UITableView* table;
    int stackNum;
    BOOL working;
    UIButton* currentBtn;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    
    dataArray = [NSMutableArray array];
    
    table = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, self.view.bounds.size.height - 120)];
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    
    
    NSArray* arr = @[@"角度",@"加速计",@"步数",@"距离",@"触摸",@"位置"];
    int width = (self.view.bounds.size.width - (arr.count+1)*10)/arr.count;
    for (int i = 0; i < arr.count; i++ ) {
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((width+10)*i + 10, self.view.bounds.size.height - 40, width, 40);
        [btn setBackgroundColor:[UIColor redColor]];
        [btn addTarget:self action:@selector(actionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:arr[i] forState:0];
        [btn setTitle:@"停止" forState:UIControlStateSelected];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        btn.tag = i;
        [self.view addSubview:btn];
    }

    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(30.541844),@"latitude",@(104.063019),@"longitude", nil];
    NSLog(@"weight = %f",[[DMLocationModel sharedInstance]getWeight:dic]);
    
    
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(.112),@"pitch",@(.21),@"roll",@(.1),@"yaw", nil];
//    NSLog(@"weight = %f",[[DMAngleModel sharedInstance] getMontionAnalyzeData:dic]);
}



#pragma mark - btn action

- (void)actionBtnClicked:(UIButton*)sender {
    
    if (currentBtn == sender) {
        sender.selected = !sender.selected;
        if (sender.selected) {
            [currentBtn setBackgroundColor:[UIColor greenColor]];
            [[CollectDataManager shareInstance] startWork];
        }else{
            [currentBtn setBackgroundColor:[UIColor redColor]];
            [[CollectDataManager shareInstance] stopWork];
        }
    }else{
        if (currentBtn) {
            currentBtn.selected = NO;
            [currentBtn setBackgroundColor:[UIColor redColor]];
            [[CollectDataManager shareInstance] stopWork];
        }
        
        sender.selected = YES;
        [sender setBackgroundColor:[UIColor greenColor]];
        [[CollectDataManager shareInstance] startWork];
        
        currentBtn = sender;
    }
    
    
    [self removeAllNotification];
    if (currentBtn.tag == 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMotionDataNotification:) name:kUpdateMotionNotification object:nil];
    }else if (currentBtn.tag == 1){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMotionDataNotification:) name:kUpdateAccelerometerNotification object:nil];
    }else if (currentBtn.tag == 2){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMotionDataNotification:) name:kUpdateStepNotification object:nil];
    }else if (currentBtn.tag == 3){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMotionDataNotification:) name:kUpdateDistanceNotification object:nil];
    }else if (currentBtn.tag == 4){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMotionDataNotification:) name:kUpdateTouchNotification object:nil];
    }else if (currentBtn.tag == 5){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMotionDataNotification:) name:kUpdateLocationNotification object:nil];
    }
}


- (void)removeAllNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - ReloadDataNotification
- (void)reloadMotionDataNotification:(NSNotification*)_noti{
    NSString* dic = [_noti object];
    
    if (dataArray.count >= 12) {
        [dataArray removeObjectAtIndex:0];
    }
    [dataArray addObject:dic];
    
    if (stackNum > 0) {
        return;
    }
    
    stackNum ++;
    while (stackNum > 0) {
        sleep(0.5);
        break;
    }
    stackNum = 0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        mArray = [dataArray copy];
        [table reloadData];
    });
}


#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return mArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"kCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"kCell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@",mArray[indexPath.row]];
    return cell;
}

@end
