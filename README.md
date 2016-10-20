#godcalendar
=======================
##初始化
----------------------
GodCalendar *godCalendar = [GodCalendar calendar]; 
##在添加到视图之前调用
godCalendar.delegate = self;
##添加到视图
[self.view addSubview:godCalendar];                 
##在添加到视图之后调用
[godCalendar setButtonTitle:@"btn"];
##手动设置日期
-(void)setCustomDate: (NSDate *)date{
      
          [godCalendar setDate:[NSDate date]];                
}

###设置代理<GodCalendarDelegate>
--------------------
##pragma 点击选择某一天返回日期
-(void)godCalendarDidSelectedWithDate: (NSDate *)date{ 
###didSelectedDate:2016-10-20 00:00:00 +0000
      NSLog(@"didSelectedDate:%@",date); 
}

#pragma 获取具体年月日数据
-(GodCalendarData *)godCalendarDataWithDay:(int)day andMonth:(int)month andYear:(int)year{                   
###需要展示的数据
      GodCalendarData *data = [[GodCalendarData alloc] init]; 
###当前数据
      data.curValues = [NSMutableArray arrayWithObjects:@21, @40, @1, nil];       
###目标数据
      data.maxValues = [NSMutableArray arrayWithObjects:@123, @100, @3, nil];    
      return data;
}
