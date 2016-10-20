//
//  DayView.m
//  GodCalendar
//
//  Created by ganyi on 2016/10/17.
//  Copyright © 2016年 ganyi. All rights reserved.
//

#import "DayView.h"
#import "GCConfigure.h"
#import "GodCalendar.h"
@interface DayView(){
    BOOL isSelected;        //标记是否选中
    CGFloat refreshRadius;  //最大圆形半径
}
@property (nonatomic, strong) UILabel *label;                       //当前日期显示
@property (nonatomic, strong) CAShapeLayer *backgroundShapeLayer;   //背景形状
@property (nonatomic, strong) NSMutableArray *shapeLayerList;       //存储所有数据形状
@property (nonatomic, strong) NSArray *shapeColorList;              //存储数据颜色

@property (nonatomic, strong) CABasicAnimation *strokeAnim;
@end

@implementation DayView

+(DayView *)node{
    return [[DayView alloc] init];
}

- (id)init{
    CGFloat radius = [[UIScreen mainScreen] bounds].size.width / 8;
    CGRect frame = CGRectMake(0, 0, radius, radius);
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
        [self createContents];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUnselectNotify object:nil];
}

- (void)drawRect:(CGRect)rect {
    
}

-(void)config{
    
    //初始化
    isSelected = false;
    refreshRadius = self.frame.size.height / 2 * 0.8;       //最大半径
    _shapeLayerList = [NSMutableArray array];
    _curValues = [NSMutableArray array];
    _maxValues = [NSMutableArray array];
    
    //初始化动画
    _strokeAnim = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    [_strokeAnim setFromValue: @-.5];
    [_strokeAnim setDuration:1.5];
    [_strokeAnim setFillMode:kCAFillModeBoth];
    [_strokeAnim setRemovedOnCompletion:NO];
    
    //设置
    [self setBackgroundColor:[UIColor clearColor]];
    [self setUserInteractionEnabled:YES];
    _shapeColorList = @[[UIColor orangeColor],
                        [UIColor yellowColor],
                        [UIColor cyanColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receviseSelectNotify:) name:kUnselectNotify object:nil];
}

-(void)createContents{

    //绘制背景圆盘
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter: CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
                          radius: refreshRadius
                      startAngle: 0
                        endAngle: M_PI * 2
                       clockwise: true];
    _backgroundShapeLayer = [CAShapeLayer layer];
    [_backgroundShapeLayer setFillColor:[[UIColor orangeColor] colorWithAlphaComponent:.5].CGColor];
    [_backgroundShapeLayer setLineWidth:0];
    [_backgroundShapeLayer setLineCap:kCALineCapRound];
    [_backgroundShapeLayer setPath:[bezierPath CGPath]];
    [_backgroundShapeLayer setZPosition:0];
    [self.layer addSublayer:_backgroundShapeLayer];
    
    //初始化日期文字
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [_label setTextAlignment:NSTextAlignmentCenter];
    [_label.layer setZPosition:3];
    [self addSubview:_label];
}

#pragma didSet_date
-(void)setDate:(NSDate *)date{
    
    //清除数据
    [_curValues removeAllObjects];
    [_maxValues removeAllObjects];
    
    //设置日期
    _date = date;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    //修改显示日期
    [formatter setDateFormat:@"dd"];
    NSString *dayStr = [formatter stringFromDate:date];
    [_label setText:dayStr];
    
    //当前日期回调
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    NSString *selectDateStr = [formatter stringFromDate:[GCConfigure shareInstance].selectedDate];
    if ([dateStr isEqualToString:selectDateStr]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUnselectNotify object:nil];
        [self setSelect:YES];
        
        //自动滑动
        if (![GCConfigure shareInstance].isGodCalendarOpened) {
            _dayViewBlock(date, YES);
        }
    }
}

#pragma didSet_curValues
-(void)setCurValues: (NSMutableArray *)curValues{
    
    [_curValues removeAllObjects];
    [_curValues addObjectsFromArray:curValues];
    if (_maxValues && ![GCConfigure shareInstance].isGodCalendarOpened) {
        
        [self createShapesWithCurValues:curValues withMaxValues:_maxValues];
    }
}

#pragma didSet_maxValues
-(void)setMaxValues:(NSMutableArray *)maxValues{
    if (_maxValues.count == 0) {
        [_maxValues addObjectsFromArray:maxValues];
        if (_curValues) {
            
            [self createShapesWithCurValues:_curValues withMaxValues:maxValues];
        }
    }
}

-(void)createShapesWithCurValues: (NSMutableArray *)curVal withMaxValues: (NSMutableArray *)maxVal{
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    if (_maxValues.count > 0 && _curValues.count > 0 && _maxValues.count == _curValues.count) {
        for (int i = 0; i < _maxValues.count; i++) {
            
            CGFloat curValue = [_curValues[i] floatValue];
            CGFloat maxValue = [_maxValues[i] floatValue];
            
            //绘制圆形们
            CGFloat lineWidth = refreshRadius * .15;
            CGFloat radius = self.frame.size.height / 2 * .7 - i * lineWidth;
            [bezierPath removeAllPoints];
            [bezierPath addArcWithCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
                                  radius:radius
                              startAngle:-M_PI_2
                                endAngle:M_PI * 1.5
                               clockwise:YES];
            
            int listCount = (int)_shapeLayerList.count;
            
            if ((listCount - 1) < i) {
            
                CAShapeLayer *shapeLayer = [CAShapeLayer layer];
                [shapeLayer setLineWidth:lineWidth];
                UIColor *color = _shapeColorList[i];
                [shapeLayer setStrokeColor:color.CGColor];
                [shapeLayer setFillColor:[UIColor clearColor].CGColor];
                [shapeLayer setPath:bezierPath.CGPath];
                [shapeLayer setZPosition:1];
                [shapeLayer setLineCap:kCALineCapRound];
                //[shapeLayer setShadowRadius:1];
                //[shapeLayer setShadowColor:[UIColor blackColor].CGColor];
                //[shapeLayer setShadowOffset:CGSizeMake(-1, 1)];
                //[shapeLayer setShadowOpacity:.5];
                
                [_shapeLayerList addObject:shapeLayer];
                [self.layer addSublayer:shapeLayer];
            }
            
            //添加动画
            CAShapeLayer *dataShapeLayer = _shapeLayerList[i];
            if ([GCConfigure shareInstance].isGodCalendarOpened) {
                [dataShapeLayer setStrokeEnd: curValue / maxValue];
            }else{
                
                [_strokeAnim setToValue: @(curValue / maxValue)];
                [dataShapeLayer addAnimation:_strokeAnim forKey: @"data"];
            }
        }
    }
}

#pragma 接收按钮取消选中消息
-(void)receviseSelectNotify: (NSNotification *)notify{
    [self setSelect:NO];
}

#pragma 设置点选状态
-(void)setSelect: (BOOL)flag{
    
    if (isSelected || flag) {
        isSelected = flag;
        
        UIColor *color;
        if (flag) {
            color = [[UIColor greenColor] colorWithAlphaComponent: .5];
        }else{
            color = [[UIColor orangeColor] colorWithAlphaComponent: .5];
        }
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"fillColor"];
        [anim setToValue: (id)[color CGColor]];
        [anim setDuration:.3];
        [anim setFillMode:kCAFillModeBoth];
        [anim setRemovedOnCompletion:NO];

        [_backgroundShapeLayer addAnimation:anim forKey:@"select"];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (_date) {
        
        [GCConfigure shareInstance].selectedDate = _date;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUnselectNotify object:nil];
        [self setSelect:YES];
        _dayViewBlock(_date, NO);
    }
}
@end
