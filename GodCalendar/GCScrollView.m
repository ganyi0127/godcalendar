//
//  GCScrollView.m
//  GodCalendar
//
//  Created by ganyi on 2016/10/17.
//  Copyright © 2016年 ganyi. All rights reserved.
//

#import "GCScrollView.h"
#import "GodCalendar.h"
#import "DayView.h"
#import "GCConfigure.h"
#import "CustomDate.h"

@interface GCScrollView()<UIScrollViewDelegate>{
    CGFloat cellWidth;                  //单元格宽度
    CGFloat willStartContentOffsetX;    //判断page滚动
    CGFloat willEndContentOffsetX;
    int monthOffset;                    //月份偏移值
}

@property (nonatomic, strong) NSCalendar *calendar;     //日历

@property (nonatomic, strong) NSMutableArray *dayViewOfCollectionList;      //回收数组
@property (nonatomic, strong) NSMutableArray *dayViewOfThisMonth;           //当前月
@property (nonatomic, strong) NSMutableArray *dayViewOfLastMonth;           //上个月
@property (nonatomic, strong) NSMutableArray *dayViewOfNextMonth;           //下个月
@property (nonatomic, strong) NSMutableArray *dayViewOfSelectedMonth;       //当前选择月
@end

@implementation GCScrollView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
        [self createContents];
    }
    return self;
}

-(void)didMoveToSuperview{
    [self initCalendar];
    [self setNeedsDisplay];
}

-(void)config{
    
    //[self setUserInteractionEnabled:YES];
    [self setShowsVerticalScrollIndicator:NO];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setPagingEnabled:YES];
    [self setDelegate:self];
    
    //初始化
    cellWidth = self.frame.size.width / 7;      //单元格宽度
    _calendar = [NSCalendar currentCalendar];   //日历
    monthOffset = 0;
    _dayViewOfCollectionList = [[NSMutableArray alloc] init];
    _dayViewOfThisMonth = [[NSMutableArray alloc] init];
    _dayViewOfLastMonth = [[NSMutableArray alloc] init];
    _dayViewOfNextMonth = [[NSMutableArray alloc] init];
    _dayViewOfSelectedMonth = [[NSMutableArray alloc] init];
    
}

-(void)createContents{
    
}

#pragma 初始化日历元素
-(void)initCalendar{
    for (UIView *obj in [self subviews]) {
        [obj removeFromSuperview];
    }
    
    //获取当月天数
    NSRange range = [_calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[NSDate date]];
    int numberOfDaysInMonth = range.length;
    for (int i = 0; i < numberOfDaysInMonth; i++) {
        DayView *dayView;
        if (_dayViewOfCollectionList.count == 0) {
            dayView = [DayView node];
        }else{
            dayView = [_dayViewOfCollectionList lastObject];
            [_dayViewOfCollectionList removeLastObject];
        }
        [self addSubview:dayView];
        [_dayViewOfThisMonth addObject:dayView];
    }
    
    [_dayViewOfSelectedMonth removeAllObjects];
    [_dayViewOfSelectedMonth addObjectsFromArray:_dayViewOfThisMonth];
    //重新排列 并赋值
    [self editWithOpenState:NO];
}

#pragma 重新排列
-(void)editWithOpenState: (BOOL)flag{
    [GCConfigure shareInstance].isGodCalendarOpened = flag;
    
    //当前月第一天星期数_月天数
    NSRange range = [_calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[GCConfigure shareInstance].selectedDate];
    int numberOfDaysInMonth = range.length;

    NSDateComponents *components = [_calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                fromDate:[GCConfigure shareInstance].selectedDate];
    components.day = 1; //用于获取1号星期数
    if (flag) {
        CustomDate *customDate = [self digureDateWithMonth:(int)components.month
                                                  withYear:(int)components.year
                                                withOffset:monthOffset];
        components.month = customDate.month;
        components.year = customDate.year;
    }
    int weekDay = (int)[_calendar component:NSCalendarUnitWeekday fromDate:[_calendar dateFromComponents:components]];
    NSTimeInterval duration;
    if (flag) {
        //打开日历
        self.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height);
        self.contentOffset = CGPointMake(self.frame.size.width, 0);
        duration = .8;
        
        if (_dayViewOfThisMonth.count == 0) {
            monthOffset = 0;
            [_dayViewOfThisMonth addObjectsFromArray:_dayViewOfSelectedMonth];
        }

        //排列
        for (int i = 0; i < _dayViewOfThisMonth.count; i++) {
            int dayIndex = i + 1;
            DayView *dayView = _dayViewOfThisMonth[i];
            
            CGFloat posX = ((dayIndex + weekDay - 2) % 7) * cellWidth + cellWidth / 2 - dayView.frame.size.width / 2 + self.frame.size.width;
            CGFloat posY = ((dayIndex + weekDay - 2) / 7) * cellWidth + self.frame.size.height * .3;
            CGPoint origin = CGPointMake(posX, posY);
            
            //移动
            [dayView setFrame:CGRectMake(origin.x, origin.y, dayView.frame.size.width, dayView.frame.size.height)];
        }
        
        //创建或销毁其他月份
        [self resetLastAndNextMonthWithOpenState:YES];
      
    }else{
        //关闭日历
        //根据当前月份天数添加或删减dayView
        while (numberOfDaysInMonth != _dayViewOfSelectedMonth.count) {
            if (numberOfDaysInMonth > _dayViewOfSelectedMonth.count) {
                //添加
                //获取最后一天日期
                DayView *lastDayViewOfThisMonth = [_dayViewOfSelectedMonth lastObject];
                NSDate *date = [[NSDate alloc] initWithTimeInterval:60 * 60 * 24
                                                          sinceDate:lastDayViewOfThisMonth.date];
                
                DayView *dayView;
                if (_dayViewOfCollectionList.count == 0) {
                    dayView = [DayView node];
                }else{
                    dayView = [_dayViewOfCollectionList lastObject];
                    [_dayViewOfCollectionList removeLastObject];
                }
                
                [dayView setDate:date];
                
                //获取数据
                NSDateComponents *components = [_calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
                GodCalendarData *godCalendarData = _dataBlock((int)components.day, (int)components.month, (int)components.year);
                [dayView setCurValues:godCalendarData.curValues];
                [dayView setMaxValues:godCalendarData.maxValues];
                
                [self addSubview:dayView];
                [_dayViewOfSelectedMonth addObject:dayView];
            }else{
                //删除
                DayView *dayView = [_dayViewOfSelectedMonth lastObject];
                [_dayViewOfSelectedMonth removeLastObject];
                [dayView removeFromSuperview];
                [_dayViewOfCollectionList addObject:dayView];
            }
        }
       
        //content范围
        self.contentSize = CGSizeMake(self.frame.size.width * ((numberOfDaysInMonth + weekDay) / 7 + ((numberOfDaysInMonth + weekDay) % 7 == 0 ? 0 : 1)),
                                      self.frame.size.height);
        NSTimeInterval duration = .2;
        
        //移除其他元素_其他月份的dayView
        for (id subView in self.subviews) {
            if ([subView isKindOfClass:[DayView class]]) {
                if (![_dayViewOfSelectedMonth containsObject:subView]) {
                    [subView removeFromSuperview];
                    [_dayViewOfCollectionList addObject:subView];
                }
            }
        }
      
        [_dayViewOfNextMonth removeAllObjects];
        [_dayViewOfLastMonth removeAllObjects];
        [_dayViewOfThisMonth removeAllObjects];
        
        monthOffset = 0;
        
        //排列
        __weak typeof (self)Self = self;      
        for (int i = 0; i < _dayViewOfSelectedMonth.count; i++) {
            
            DayView *dayView = _dayViewOfSelectedMonth[i];
            int dayIndex = i + 1;
            
            CGFloat posX = (dayIndex - 1) * cellWidth + cellWidth / 2 - dayView.frame.size.width / 2 + (weekDay - 1) * cellWidth;
            CGFloat posY = self.frame.size.height / 2 - dayView.frame.size.height / 2;
            CGPoint origin = CGPointMake(posX, posY);
            
            //点击回调设置_1
            dayView.dayViewBlock = ^(NSDate *date, BOOL needDisplayDate){
                //自动滚动到当前日期
                if (needDisplayDate) {
                    
                    CGPoint offset = CGPointMake(Self.frame.size.width * (int)((dayIndex + weekDay - 2) / 7),
                                                 0);
                    [Self setContentOffset:offset animated:YES];
                }
                
                Self.scrollBlock(date);
            };
            
            //设置日期_2
            components.day = dayIndex;
            
            NSDate *date = [_calendar dateFromComponents:components];
            NSTimeZone *zone = [NSTimeZone systemTimeZone];
            NSTimeInterval deltaTime = [zone secondsFromGMTForDate:date];
            NSDate *realDate = [date dateByAddingTimeInterval:deltaTime];
            
            //修改日期
            [dayView setDate:realDate];
            
            //获取数据
            GodCalendarData *godCalendarData = _dataBlock((int)components.day, (int)components.month, (int)components.year);
            [dayView setCurValues:godCalendarData.curValues];
            [dayView setMaxValues:godCalendarData.maxValues];
            
            //移动
            [UIView animateWithDuration:duration animations:^{
                [dayView setFrame:CGRectMake(origin.x, origin.y, dayView.frame.size.width, dayView.frame.size.height)];
            }];
        }
    }
}

#pragma 创建或清除上个月与下个月dayView
-(void)resetLastAndNextMonthWithOpenState: (BOOL)flag{
    
    if (!flag) {
        return;
    }
    
    NSDateComponents *components;
    NSRange range;
    
    //获取上个月
    components = [_calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[GCConfigure shareInstance].selectedDate];
    CustomDate *customDate = [self digureDateWithMonth:(int)(components.month - 1) withYear:(int)components.year withOffset:monthOffset];
    components.day = 1;
    components.month = customDate.month;
    components.year = customDate.year;
    
    NSDate *lastDate = [_calendar dateFromComponents:components];
    
    range = [_calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:lastDate];
    int numberOfDaysInLastMonth = (int)range.length;
    int lastWeekday = (int)[_calendar component:NSCalendarUnitWeekday fromDate:[_calendar dateFromComponents:components]];
    
    __weak typeof (self)Self = self;
    //判断上个月是否为空
    if (_dayViewOfLastMonth.count == 0) {
        for (int i = 0; i < numberOfDaysInLastMonth; i++) {
            int dayIndex = i + 1;
            DayView *dayView;
            
            if (_dayViewOfCollectionList.count == 0) {
                dayView = [DayView node];
            }else{
                dayView = [_dayViewOfCollectionList lastObject];
                [_dayViewOfCollectionList removeLastObject];
            }
            
            [self addSubview:dayView];
            
            //保存为上一月
            [_dayViewOfLastMonth addObject:dayView];
            
            //位置
            CGFloat posX = (dayIndex + lastWeekday - 2) % 7 * cellWidth + cellWidth / 2 - dayView.frame.size.width / 2;
            CGFloat posY = (CGFloat)(dayIndex + lastWeekday - 2) / 7 * cellWidth + self.frame.size.width * .3;
            [dayView setFrame: CGRectMake(posX, posY, dayView.frame.size.width, dayView.frame.size.height)];
            
            //设置日期_2
            components.day = dayIndex;
            [dayView setDate:[_calendar dateFromComponents:components]];
            
            //获取数据
            GodCalendarData *godCalendarData = _dataBlock((int)components.day, (int)components.month, (int)components.year);
            [dayView setCurValues:godCalendarData.curValues];
            [dayView setMaxValues:godCalendarData.maxValues];
            
            
            //点击回调
            dayView.dayViewBlock = ^(NSDate *date, BOOL needDisplayDate){
                //自动滑动到当前日期
                if (needDisplayDate) {
                    CGPoint offset = CGPointMake(self.frame.size.width * (CGFloat)(dayIndex + lastWeekday - 2) / 7, 0);
                    [Self setContentOffset:offset animated:YES];
                }
                
                [_dayViewOfSelectedMonth removeAllObjects];
                [_dayViewOfSelectedMonth addObjectsFromArray:_dayViewOfThisMonth];
                
                _scrollBlock(date);
            };
        }
    }else{
        //排列
        for (int i = 0; i < _dayViewOfLastMonth.count; i++) {
            int dayIndex = i + 1;
            DayView *dayView = _dayViewOfLastMonth[i];
            
            CGFloat posX = (dayIndex + lastWeekday - 2) % 7 * cellWidth + cellWidth / 2 - dayView.frame.size.width / 2;
            CGFloat posY = (CGFloat)(dayIndex + lastWeekday - 2) / 7 * cellWidth + self.frame.size.height * .3;
            [dayView setFrame:CGRectMake(posX, posY, dayView.frame.size.width, dayView.frame.size.height)];
            
            //点击回调...
        }
    }
    
    //获取下个月
    components = [_calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[GCConfigure shareInstance].selectedDate];
    customDate = [self digureDateWithMonth:(int)(components.month + 1) withYear:(int)components.year withOffset:monthOffset];
    components.day = 1;
    components.month = customDate.month;
    components.year = customDate.year;
    
    NSDate *nextDate = [_calendar dateFromComponents:components];
    
    range = [_calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:nextDate];
    int numberOfDaysInNextMonth = (int)range.length;
    int nextWeekday = (int)[_calendar component:NSCalendarUnitWeekday fromDate:[_calendar dateFromComponents:components]];
    
    //判断下个月是否为空
    if (_dayViewOfNextMonth.count == 0) {
        for (int i = 0; i < numberOfDaysInNextMonth; i++) {
            int dayIndex = i + 1;
            DayView *dayView;
            
            if (_dayViewOfCollectionList.count == 0) {
                dayView = [DayView node];
            }else{
                dayView = [_dayViewOfCollectionList lastObject];
                [_dayViewOfCollectionList removeLastObject];
            }
            [self addSubview:dayView];
            
            //保存为下一个月
            [_dayViewOfNextMonth addObject:dayView];
            
            //位置
            CGFloat posX = (dayIndex + nextWeekday - 2) % 7 * cellWidth + cellWidth / 2 - dayView.frame.size.width / 2 + self.frame.size.width * 2;
            CGFloat posY = (CGFloat)(dayIndex + nextWeekday - 2) / 7 * cellWidth + self.frame.size.height * .3;
            [dayView setFrame:CGRectMake(posX, posY, dayView.frame.size.width, dayView.frame.size.height)];
            
            //设置日期_2
            components.day = dayIndex;
            [dayView setDate:[_calendar dateFromComponents:components]];
            
            //获取数据
            GodCalendarData *godCalendarData = _dataBlock((int)components.day, (int)components.month, (int)components.year);
            [dayView setCurValues:godCalendarData.curValues];
            [dayView setMaxValues:godCalendarData.maxValues];
            
            //点击回调
            dayView.dayViewBlock = ^(NSDate *date, BOOL needDisplayDate){
                //自动滑动到当前日期
                if (needDisplayDate) {
                    CGPoint offset = CGPointMake(self.frame.size.width * (CGFloat)(dayIndex + nextWeekday - 2) / 7, 0);
                    [Self setContentOffset:offset animated:YES];
                }
                
                [_dayViewOfSelectedMonth removeAllObjects];
                [_dayViewOfSelectedMonth addObjectsFromArray:_dayViewOfThisMonth];
                
                _scrollBlock(date);
            };
        }
    }else{
        //排列
        for (int i = 0; i < _dayViewOfNextMonth.count; i++) {
            int dayIndex = i + 1;
            DayView *dayView = _dayViewOfNextMonth[i];
            
            CGFloat posX = (dayIndex + nextWeekday - 2) % 7 * cellWidth + cellWidth / 2 - dayView.frame.size.width / 2 + self.frame.size.width * 2;
            CGFloat posY = (CGFloat)(dayIndex + nextWeekday - 2) / 7 * cellWidth + self.frame.size.height * .3;
            [dayView setFrame:CGRectMake(posX, posY, dayView.frame.size.width, dayView.frame.size.height)];
            
            //点击回调...
        }
    }
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

#pragma 绘图
- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
    
    //填充背景
    CGColorRef backgroundColor;
    if ([GCConfigure shareInstance].isGodCalendarOpened) {
        backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.5].CGColor;
    }else{
        backgroundColor = [UIColor whiteColor].CGColor;
    }
    CGContextSetFillColorWithColor(ctx, backgroundColor);
    CGContextFillRect(ctx, rect);
    
    //绘制文字
    if ([GCConfigure shareInstance].isGodCalendarOpened) {
        
        //抗锯齿
        CGContextSetAllowsAntialiasing(ctx, YES);
        
        //配置
        NSParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12],
                                     NSForegroundColorAttributeName: [UIColor whiteColor],
                                     NSParagraphStyleAttributeName: paragraphStyle};

        
        //绘制星期
        NSArray *textList = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
        for (int i = 0; i < textList.count; i++) {
            NSString *dataTitle = textList[i];
            CGRect dataTitleRect = [dataTitle boundingRectWithSize:self.frame.size
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:attributes
                                                           context:nil];
            dataTitleRect.origin = CGPointMake(cellWidth * i + self.frame.size.width + cellWidth / 2 - 6,
                                               self.frame.size.height * .25);
            [dataTitle drawInRect:dataTitleRect withAttributes:attributes];
        }
        
        //绘制年月
        NSDictionary *dateAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:24],
                                         NSForegroundColorAttributeName: [UIColor whiteColor],
                                         NSParagraphStyleAttributeName: paragraphStyle};
        NSDateComponents *components = [_calendar components:NSCalendarUnitYear | NSCalendarUnitMonth
                                                    fromDate:[GCConfigure shareInstance].selectedDate];
        CustomDate *customDate = [self digureDateWithMonth: (int)[components month]
                                                  withYear: (int)[components year]
                                                withOffset:monthOffset];
        NSString *dateTitle = [NSString stringWithFormat:@"%d年 %d月", customDate.year, customDate.month];
        CGRect dateTitleRect = [dateTitle boundingRectWithSize:self.frame.size
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:dateAttributes
                                                       context:nil];
        dateTitleRect.origin = CGPointMake(cellWidth + self.frame.size.width + cellWidth / 2,
                                           self.frame.size.height * .15);
        [dateTitle drawInRect:dateTitleRect withAttributes:dateAttributes];
    }
}

#pragma 计算偏移后的月份 curMonth = month - 1
-(CustomDate *)digureDateWithMonth: (int)curMonth withYear: (int)curYear withOffset: (int)offset{
    
    int month = curMonth + offset;
    int yearOffset = 0;
    
    while (month <= 0) {
        month += 12;
        yearOffset -= 1;
    }
    
    while (month > 12) {
        month -= 12;
        yearOffset += 1;
    }
    
    CustomDate *result = [[CustomDate alloc] init];
    result.month = month;
    result.year = curYear + yearOffset;
    return result;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    willStartContentOffsetX = scrollView.contentOffset.x;
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    willEndContentOffsetX = scrollView.contentOffset.x;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([GCConfigure shareInstance].isGodCalendarOpened) {
        if (self.contentOffset.x == self.frame.size.width * 2) {
            //左滑
            for (DayView *dayView in _dayViewOfLastMonth) {
                if (![_dayViewOfSelectedMonth containsObject:dayView]) {
                    [dayView removeFromSuperview];
                    [_dayViewOfCollectionList addObject:dayView];
                }
            }
            
            [_dayViewOfLastMonth removeAllObjects];
            [_dayViewOfLastMonth addObjectsFromArray:_dayViewOfThisMonth];
            [_dayViewOfThisMonth removeAllObjects];
            [_dayViewOfThisMonth addObjectsFromArray:_dayViewOfNextMonth];
            [_dayViewOfNextMonth removeAllObjects];
            monthOffset += 1;
            
        }else if (self.contentOffset.x == 0){
            //右滑
            for (DayView *dayView in _dayViewOfNextMonth) {
                if (![_dayViewOfSelectedMonth containsObject:dayView]) {
                    [dayView removeFromSuperview];
                    [_dayViewOfCollectionList addObject:dayView];
                }
            }
            
            [_dayViewOfNextMonth removeAllObjects];
            [_dayViewOfNextMonth addObjectsFromArray:_dayViewOfThisMonth];
            [_dayViewOfThisMonth removeAllObjects];
            [_dayViewOfThisMonth addObjectsFromArray:_dayViewOfLastMonth];
            [_dayViewOfLastMonth removeAllObjects];
            monthOffset -= 1;
        }
        
        [self editWithOpenState: YES];
        [self setNeedsDisplay];
        
    }else{
        monthOffset = 0;
    }
}
@end
