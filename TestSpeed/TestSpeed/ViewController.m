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
    UIAlertView* view = [[UIAlertView alloc]initWithTitle:@"" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [view show];
}

@interface ViewController ()

@property (nonatomic,strong) CMMotionManager* motionManager;
@property (atomic,strong)NSRunLoop* childRunLoop;
@property (atomic,strong)dispatch_queue_t queue;
@property (atomic,strong)NSThread* thread;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSTimeInterval period = 1.0; //设置时间间隔
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
//    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
//    dispatch_source_set_event_handler(_timer, ^{
//        //在这里执行事件
//        NSLog(@"执行AAAAA");
//    });
//    dispatch_resume(_timer);
    
    
//    self.thread = [[NSThread alloc]initWithTarget:self selector:@selector(threadWorkPro:) object:self];
//    [self.thread start];

    __block NSString* str = nil;
    self.motionManager=[[CMMotionManager alloc]init];
    if (!self.motionManager.accelerometerAvailable) {
        // 检查传感器到底在设备上是否可用
        messageBox(@"传感器设备不可用");
        return;
    }
    
    self.motionManager.gyroUpdateInterval=0.1;  //更新频率是10Hz
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
        str = [NSString stringWithFormat:@"旋转角度:X:%.3f,Y:%.3f,Z:%.3f",gyroData.rotationRate.x,gyroData.rotationRate.y,gyroData.rotationRate.z];
        //messageBox(str);
        [self writeFile:str WithFileName:@"旋转角度.txt"];
    }];
    
    self.motionManager.accelerometerUpdateInterval=0.1;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        str = [NSString stringWithFormat:@"加速计:X:%.3f,Y:%.3f,Z:%.3f",accelerometerData.acceleration.x,accelerometerData.acceleration.y,accelerometerData.acceleration.z];
        //messageBox(str);
        [self writeFile:str WithFileName:@"加速计.txt"];
    }];
}

- (void)writeFile:(NSString*)str WithFileName:(NSString*)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [paths objectAtIndex:0];

    NSString* strFile = [docDir stringByAppendingFormat:@"/%@", fileName];
    NSFileManager* fileMgr = [[NSFileManager alloc]init];
    if (![fileMgr fileExistsAtPath:strFile]) {
        BOOL isCreate = [fileMgr createFileAtPath:strFile contents:nil attributes:nil];
        if (!isCreate) return;
    }
    NSFileHandle* outFile = [NSFileHandle fileHandleForWritingAtPath:strFile];
    if (!outFile) return;
    [outFile seekToEndOfFile];
    
    NSString* writeData = nil;
    if (!outFile.offsetInFile) {
        writeData = [[NSMutableString alloc]initWithFormat:@"%@",str];
    }
    else {
        writeData = [[NSMutableString alloc]initWithFormat:@"\r\n%@",str];
    }
    NSData *buffer = [writeData dataUsingEncoding:NSUTF8StringEncoding];
    [outFile writeData:buffer];
    
    [outFile closeFile];
}

- (void)threadWorkPro:(NSObject*)obj {
    //__weak ViewController* weakSelf = (ViewController*)obj;
    while (![[NSThread currentThread]isCancelled]) {
        NSLog(@"执行");
        sleep(10);
    }
    NSLog(@"结束");
}

- (IBAction)stopBtnClicked:(id)sender {
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopGyroUpdates];
    [self.thread cancel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
