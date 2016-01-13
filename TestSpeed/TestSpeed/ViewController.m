//
//  ViewController.m
//  TestSpeed
//
//  Created by liuxu on 16/1/8.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import "ViewController.h"
#import "Health/HealthManager.h"
#import "MotionManager/MotionManager.h"

#define kSpeedFileName  @"加速计.txt"
#define kAngleFileName  @"旋转角度.txt"
#define kStepFileName   @"实时步数.txt"

void messageBox(NSString* str) {
    UIAlertView* view = [[UIAlertView alloc]initWithTitle:@"" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [view show];
}

@interface ViewController ()

@property (nonatomic,strong)NSTimer* timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)startBtnClicked:(id)sender {
    if (!_timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerWorking) userInfo:nil repeats:YES];
    }
}

- (IBAction)stopBtnClicked:(id)sender {
    [self.timer invalidate];
    self.timer = nil;
    //停止速度、加速度、角度检测器
    [[MotionManager shareInstance] stop];
}

- (void)timerWorking {
    static BOOL isFirst = YES;
    //开启速度、加速度、角度检测器
    if (isFirst) {
        [self getMontionInfo];
        isFirst = NO;
    }
    //获取实时步数量
    [self getHealthInfo];
}

- (void)getMontionInfo {
    if (![[MotionManager shareInstance]checkDevice]) {
        messageBox(@"当前系统版本不支持获取加速度、角度信息");
        return;
    }
    
    __block NSString* str = nil;
    __weak typeof(self) weakSelf = self;
    [[MotionManager shareInstance]startMotionManagerWork:^(CMGyroData *gyroData, NSError *error) {
        str = [NSString stringWithFormat:@"旋转角度:X:%.3f,Y:%.3f,Z:%.3f",gyroData.rotationRate.x,gyroData.rotationRate.y,gyroData.rotationRate.z];
        [weakSelf writeFile:str WithFileName:kAngleFileName];
    } accelerometer:^(CMAccelerometerData *accelerometerData, NSError *error) {
        str = [NSString stringWithFormat:@"加速计:X:%.3f,Y:%.3f,Z:%.3f",accelerometerData.acceleration.x,accelerometerData.acceleration.y,accelerometerData.acceleration.z];
        [weakSelf writeFile:str WithFileName:kSpeedFileName];
    }];
}

- (void)getHealthInfo {
    if (![[HealthManager shareInstance]checkDevice]) {
        messageBox(@"当前系统版本不支持获取健康数据信息");
        return;
    }
    
    [[HealthManager shareInstance] getRealTimeStepCountCompletionHandler:^(double value, NSError *error) {
        NSString* str = [[NSString alloc]initWithFormat:@"当前步数：%d", (int)value];
        [self writeFile:str WithFileName:kStepFileName];
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

@end
