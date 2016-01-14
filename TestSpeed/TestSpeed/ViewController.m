//
//  ViewController.m
//  TestSpeed
//
//  Created by liuxu on 16/1/8.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import "ViewController.h"
#import "CollectDataManager.h"

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
    
    NSArray* arr = @[@"角度",@"加速计",@"步数"];
    for (int i = 0; i < 3; i++ ) {
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(80*i + 20, CGRectGetMaxY(table.frame) + 10, 60, 40);
        [btn setBackgroundColor:[UIColor redColor]];
        [btn addTarget:self action:@selector(actionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:[NSString stringWithFormat:@"%@开始",arr[i]] forState:0];
        [btn setTitle:[NSString stringWithFormat:@"%@停止",arr[i]] forState:UIControlStateSelected];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        btn.tag = i;
        [self.view addSubview:btn];
    }
    
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
        [dataArray removeAllObjects];

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMotionDataNotification:) name:@"UpdateMotionNotification" object:nil];
    }else if (currentBtn.tag == 1){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMotionDataNotification:) name:@"UpdateAccelerometerNotification" object:nil];
    }else if (currentBtn.tag == 2){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMotionDataNotification:) name:@"UpdateStepNotification" object:nil];
    }
}


- (void)removeAllNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateMotionNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateAccelerometerNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateStepNotification" object:nil];
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
