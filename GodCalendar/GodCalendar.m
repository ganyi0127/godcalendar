//
//  GodCalendar.m
//  GodCalendar
//
//  Created by ganyi on 2016/10/17.
//  Copyright © 2016年 ganyi. All rights reserved.
//

#import "GodCalendar.h"
#import "GCScrollView.h"
#import "GCConfigure.h"

@interface GodCalendar(){
    
    CGRect calendarFrame;               //日历展开视窗尺寸
    CGRect viewFrame;                   //显示视窗尺寸、日历折叠视窗尺寸
    CGRect buttonFrame;                 //默认按钮尺寸
}
@property (nonatomic, strong) UILabel *label;           //日期显示标签
@property (nonatomic, strong) UIButton *button;         //日历开关按钮
@property (nonatomic, strong) GCScrollView *scrollView; //日历滚动视图
@end

@implementation GodCalendar

+ (id)calendar{

    CGRect frame = CGRectMake(0, 0, kWinSize.width, kWinSize.height);
    
    return [[GodCalendar alloc] initWithFrame:frame];
}

#pragma 初始化 frame:日历展开后视窗大小
- (instancetype)initWithFrame:(CGRect)frame{
    calendarFrame = frame;

    //计算基础view高度
    CGFloat viewHeight = calendarFrame.size.height / 8;
    NSLog(@"frame:%f-%f-%f-%f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
    //计算显示视窗尺寸
    viewFrame = CGRectMake(frame.origin.x,
                           frame.origin.y + viewHeight,
                           kWinSize.width,
                           viewHeight);
    self = [super initWithFrame:viewFrame];
    if (self) {
        [self config];
        //[self createContents];
    }
    return self;
}

#pragma release
-(void)dealloc{
    
}

-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    
    [self createContents];
}

-(void)config{
    
    //初始化全局设置
    [GCConfigure shareInstance].selectedDate = [NSDate date];
    [GCConfigure shareInstance].isGodCalendarOpened = NO;

    //设置
    [self setBackgroundColor:[UIColor clearColor]];
}

-(void)createContents{
    
    //初始化scrollView
    CGRect scrollViewFrame = CGRectMake(0,
                                        0,
                                        viewFrame.size.width,
                                        viewFrame.size.height / 2);
    _scrollView = [[GCScrollView alloc] initWithFrame:scrollViewFrame];
    __weak typeof (self)Self = self;
    _scrollView.scrollBlock = ^(NSDate *date){
        
        [Self updateLabelTitleWithDate:date];
        
        //收起日历
        if ([GCConfigure shareInstance].isGodCalendarOpened) {
            [Self clickButton];
        }else{
            [Self.delegate godCalendarDidSelectedWithDate:date];
        }
    };
    
    _scrollView.dataBlock = ^(int day, int month, int year){
        return [Self.delegate godCalendarDataWithDay:day andMonth:month andYear:year];
    };
    [self addSubview:_scrollView];
    
    
    
    //初始化日期label
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                       viewFrame.size.height / 2,
                                                       viewFrame.size.width,
                                                       viewFrame.size.height / 2)];
    [_label setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent: .5]];
    [_label setText:@"今天"];     //默认为当前日期
    [_label setTextColor:[UIColor whiteColor]];
    [_label setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_label];
    
    //初始化按钮
    CGFloat buttonWidth = viewFrame.size.height * .8;
    buttonFrame = CGRectMake(viewFrame.size.width - buttonWidth,
                             viewFrame.size.height / 2,
                             buttonWidth,
                             viewFrame.size.height / 2);
    _button = [[UIButton alloc] initWithFrame:buttonFrame];
    [_button setTitle:@"on/off" forState:UIControlStateNormal];
    [_button setBackgroundColor:[UIColor orangeColor]];
    [_button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];
}

#pragma 手动设置日期
-(void)setDate:(NSDate *)date{
    [GCConfigure shareInstance].selectedDate = date;
    [_scrollView editWithOpenState:NO];
}

#pragma 更新显示日期
-(void)updateLabelTitleWithDate: (NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyy-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    NSString *todayStr = [formatter stringFromDate:[NSDate date]];
    
    //显示今天
    if ([dateStr isEqualToString:todayStr]) {
        [_label setText:@"今天"];
    }else{
        [_label setText:dateStr];
    }
}

#pragma 自定义按钮实现
-(void)setButton:(UIButton *)button{
    if (_button) {
        [_button removeFromSuperview];
    }
    
    _button = button;
    [_button setFrame:buttonFrame];
    [_button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];
}

#pragma 设置按钮文字
-(void)setButtonTitle:(NSString *)title{
    [_button setTitle:title forState:UIControlStateNormal];
}

#pragma 点击按钮切换
-(void)clickButton{
    [GCConfigure shareInstance].isGodCalendarOpened = ![GCConfigure shareInstance].isGodCalendarOpened;
    
    __weak typeof (self)Self = self;
    [UIView animateWithDuration:.3 animations:^{
        if ([GCConfigure shareInstance].isGodCalendarOpened) {
            CGRect bigFrame = CGRectMake(0, 0, self.frame.size.width, kWinSize.height);
            [self.scrollView setFrame:bigFrame];
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, bigFrame.size.width, bigFrame.size.height)];
        }else{
            CGRect smallFrame = CGRectMake(0, 0, self.frame.size.width, viewFrame.size.height / 2);
            [self.scrollView setFrame:smallFrame];
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, viewFrame.size.width, viewFrame.size.height)];
        }
        
        [_scrollView editWithOpenState:[GCConfigure shareInstance].isGodCalendarOpened];
    }];
}
#pragma 初始化绘制
-(void)drawRect:(CGRect)rect{
    
}

@end
