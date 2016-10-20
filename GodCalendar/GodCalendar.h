//
//  GodCalendar.h
//  GodCalendar
//
//  Created by ganyi on 2016/10/17.
//  Copyright © 2016年 ganyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GodCalendarData.h"



@protocol GodCalendarDelegate <NSObject>
@required
-(void)godCalendarDidSelectedWithDate:(NSDate *)date;                                           //点击回调
-(GodCalendarData *)godCalendarDataWithDay: (int)day andMonth: (int)month andYear: (int)year;   //获取数据
@end

@interface GodCalendar : UIView

@property (nonatomic, strong) id<GodCalendarDelegate> delegate; //接收点击事件代理

+ (GodCalendar *)calendar;
-(void)setButton: (UIButton *)button;
-(void)setButtonTitle: (NSString *)title;
-(void)setDate: (NSDate *)date;                 //手动设置日期
@end
