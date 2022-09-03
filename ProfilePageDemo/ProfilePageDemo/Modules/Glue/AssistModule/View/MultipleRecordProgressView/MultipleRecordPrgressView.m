//
//  CustomProgress.swift
//  unipets-ios
//
//  Created by Future on 2021/12/2.
//

#import "MultipleRecordPrgressView.h"


#define Point self.bounds.size.width/2
#define lineWidth 4.0
#define RGBA_COLOR(R, G, B, A) [UIColor colorWithRed:((R) / 255.0f) green:((G) / 255.0f) blue:((B) / 255.0f) alpha:A]
@interface MultipleRecordPrgressView ()
{
    
    CGContextRef context;
}
@end

@implementation MultipleRecordPrgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        [self setNeedsDisplay];
    }
    return self;
}
 
- (void)drawRect:(CGRect)rect
{
    
    context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextAddArc(context, Point, Point, Point- 2.5, M_PI_2 , M_PI_2 + 2 * M_PI, 0);
    CGContextStrokePath(context);
   
    if (!self.nowArray || self.nowArray.count < 2)
    {
        return;
    }
    // 历史
    
    for (int j = 0; j < self.allArray.count; j++)
    {
        NSMutableArray *tempArray = self.allArray[j];
        
        for (int i = 0; i < tempArray.count-1; i++)
        {
            CGContextSetStrokeColorWithColor(context, [self.drawColor CGColor]);
            CGFloat startAngle = -M_PI_2 + 2 * M_PI * [tempArray[i] floatValue];
            CGFloat endAngle = -M_PI_2 + 2 * M_PI * [tempArray[i+1] floatValue];
            CGContextAddArc(context, Point, Point, Point - 2.5, startAngle, endAngle, 0);
            CGContextStrokePath(context);
        }
    }
    // 本次
    for (int i = 0; i < self.nowArray.count-1; i++)
    {
        CGContextSetStrokeColorWithColor(context, [self.drawColor CGColor]);
        CGFloat startAngle = -M_PI_2 + 2 * M_PI * [self.nowArray[i] doubleValue];
        CGFloat endAngle = -M_PI_2 + 2 * M_PI * [self.nowArray[i+1] doubleValue];
        CGContextAddArc(context, Point, Point, Point - 2.5, startAngle, endAngle, 0);
        CGContextStrokePath(context);
    }
    for (int i = 0; i < self.nowArray.count-1; i++)
    {
        CGContextSetStrokeColorWithColor(context, [self.drawColor CGColor]);
        CGFloat startAngle = -M_PI_2 + 2 * M_PI * [self.nowArray[i] doubleValue];
        CGFloat endAngle = -M_PI_2 + 2 * M_PI * [self.nowArray[i+1] doubleValue];
        CGContextAddArc(context, Point, Point, Point - 2.5, startAngle, endAngle, 0);
        CGContextStrokePath(context);
    }
    // 暂停
    for (int j = 0; j < self.pauseArray.count; j++)
    {
        CGContextSetStrokeColorWithColor(context, [self.pauseColor CGColor]);
        CGFloat startAngle = -M_PI_2 + 2 * M_PI * [self.pauseArray[j] doubleValue];
        CGFloat endAngle = -M_PI_2 + 2 * M_PI * [self.pauseArray[j] doubleValue];
        CGContextAddArc(context, Point, Point, Point - 2.5, startAngle, endAngle+0.07, 0);
        CGContextStrokePath(context);
    }
}

- (void)setProgressEnd:(CGFloat)progressEnd
{
    _progressEnd = progressEnd;
    
    [self setNeedsDisplay];
}
- (void)drawBegan
{
    self.nowArray = [NSMutableArray array];
    [self.nowArray addObject:@(self.progressEnd)];
}

- (void)drawMoved
{
    CGFloat lastValue = [self.nowArray.lastObject doubleValue];
    if (lastValue>= self.progressEnd) {
        return;
    }
    [self.nowArray addObject:@(self.progressEnd)];
    [self setNeedsDisplay];
}
-(void)drawPause{
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:self.nowArray];
    if (self.allArray)
    {
        self.allArray = [self.allArray arrayByAddingObject:tempArray];
    }
    else
    {
        self.allArray = [[NSArray alloc] initWithObjects:tempArray, nil];
    }
    [self.pauseArray addObject:@(self.progressEnd)];
}

-(void)drawDeleteLastProgress {
    
    for (NSInteger i = self.nowArray.count - 1; i >= 0 ; i--) {
        CGFloat value = [self.nowArray[i] doubleValue];
        if (value >= self.progressEnd) {
            [self.nowArray removeObjectAtIndex:i];
        }
    }
    for (NSInteger i = self.pauseArray.count - 1; i >= 0 ; i--) {
        CGFloat value = [self.pauseArray[i] doubleValue];
        if (value >= self.progressEnd) {
            [self.pauseArray removeObjectAtIndex:i];
        }
    }
    NSMutableArray * mutAllArray = [NSMutableArray arrayWithArray:self.allArray];
    if (mutAllArray.count>0) {
        [mutAllArray removeLastObject];
    }
    self.allArray =  [mutAllArray copy];
}
- (void)drawEnded
{
    
    self.pauseArray  = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self drawMoved];
        [self setNeedsDisplay];
    });
    
}
- (void)drawReset
{
    self.pauseArray  = nil;
    self.allArray    = nil;
    self.nowArray    = nil;
    self.progressEnd = 0.0;
    [self drawBegan];
    [self drawMoved];
    [self setNeedsDisplay];
}
- (UIColor *)drawColor
{
    if (!_drawColor)
    {
        _drawColor = [MultipleRecordPrgressView colorWithHexString:@"FFA10A" alpha:1.0] ;
    }
    return _drawColor;
}
-(UIColor *)pauseColor{
    if (!_pauseColor)
    {
        _pauseColor = [UIColor whiteColor];
    }
    return _pauseColor;
}
- (NSMutableArray *)pauseArray
{
    if (!_pauseArray)
    {
        _pauseArray = [NSMutableArray array];
    }
    return _pauseArray;
}
/**
 16进制颜色转换为UIColor
 
 @param hexColor 16进制字符串（可以以0x开头，可以以#开头，也可以就是6位的16进制）
 @param opacity 透明度
 @return 16进制字符串对应的颜色
 */
+(UIColor *)colorWithHexString:(NSString *)hexColor alpha:(float)opacity{
    NSString * cString = [[hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor blackColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    
    if ([cString length] != 6) return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString * rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString * gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString * bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float)r / 255.0f)
                           green:((float)g / 255.0f)
                            blue:((float)b / 255.0f)
                           alpha:opacity];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
