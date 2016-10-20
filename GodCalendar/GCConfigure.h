//
//  GCConfigure.h
//  GodCalendar
//
//  Created by ganyi on 2016/10/17.
//  Copyright © 2016年 ganyi. All rights reserved.
//

//消息
#define kUnselectNotify @"noselect_notification"

//尺寸
#define kWinSize ([UIScreen mainScreen].bounds.size)

#import <UIKit/UIKit.h>

@interface GCConfigure : NSObject
@property (nonatomic, strong) NSDate *selectedDate;             //存储当前选择的日期
@property (nonatomic, assign) BOOL isGodCalendarOpened;         //存储当前日历是否展开

+(GCConfigure *)shareInstance;
@end

