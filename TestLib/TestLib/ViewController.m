//
//  ViewController.m
//  TestLib
//
//  Created by ganyi on 2016/10/19.
//  Copyright © 2016年 ganyi. All rights reserved.
//

#import "ViewController.h"
#import "GodCalendar.h"
@interface ViewController () <GodCalendarDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createContents];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma 示例
-(void)createContents{
    
    GodCalendar *godCalendar = [GodCalendar calendar];  //初始化
    godCalendar.delegate = self;                        //在添加到视图之前调用
    [self.view addSubview:godCalendar];                 //添加到视图
    [godCalendar setButtonTitle:@"btn"];                //在添加到视图之后调用
}

#pragma 手动设置日期option
-(void)setCustomDate: (NSDate *)date{
    
    [godCalendar setDate:[NSDate date]];                //手动设置滚动日期
}


#pragma 点击选择某一天返回日期
-(void)godCalendarDidSelectedWithDate: (NSDate *)date{
    NSLog(@"didSelectedDate:%@",date);                  //didSelectedDate:2016-10-20 00:00:00 +0000
}

#pragma 获取具体年月日数据
-(GodCalendarData *)godCalendarDataWithDay:(int)day andMonth:(int)month andYear:(int)year{
    GodCalendarData *data = [[GodCalendarData alloc] init];                     //需要展示的数据
    data.curValues = [NSMutableArray arrayWithObjects:@21, @40, @1, nil];       //当前数据
    data.maxValues = [NSMutableArray arrayWithObjects:@123, @100, @3, nil];     //目标数据
    return data;
}

@end
