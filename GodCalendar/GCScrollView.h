//

//  GCScrollView.h
//  GodCalendar
//
//  Created by ganyi on 2016/10/17.
//  Copyright © 2016年 ganyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GodCalendar.h"
#import "GodCalendarData.h"

@interface GCScrollView : UIScrollView

@property (nonatomic, copy) void (^scrollBlock)(NSDate *);                  //回调
@property (nonatomic, copy) GodCalendarData *(^dataBlock)(int, int, int);   //根据年月日获取返回数据

- (instancetype)initWithFrame:(CGRect)frame;
-(void)editWithOpenState: (BOOL)flag;
@end
