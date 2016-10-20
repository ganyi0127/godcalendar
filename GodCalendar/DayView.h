//
//  DayView.h
//  GodCalendar
//
//  Created by ganyi on 2016/10/17.
//  Copyright © 2016年 ganyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DayView : UIView

@property (nonatomic, copy) void (^dayViewBlock)(NSDate *, BOOL);           //点击回调

@property (nonatomic, strong) NSDate *date;                                 //日期
@property (nonatomic, strong) NSMutableArray *curValues;                    //当前数值
@property (nonatomic, strong) NSMutableArray *maxValues;                    //最大数值

+(DayView *)node;
-(void)setCurValues: (NSMutableArray *)curValues;
-(void)setMaxValues:(NSMutableArray *)maxValues;
@end
