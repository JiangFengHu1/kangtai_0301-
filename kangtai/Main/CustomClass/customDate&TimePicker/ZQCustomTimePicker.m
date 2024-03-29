//
//
/**
 * Copyright (c) www.bugull.com
 */
//
//

#import "ZQCustomTimePicker.h"

@interface ZQCustomTimePicker () <iCarouselDelegate, iCarouselDataSource>

@property (nonatomic, assign) NSInteger nowHour;
@property (nonatomic, assign) NSInteger nowMinute;
@property (nonatomic, copy) NSString *setTimeStr;
@property (nonatomic, assign) BOOL isZero;

@end

@implementation ZQCustomTimePicker

- (id)initWithFrame:(CGRect)frame withIsZero:(BOOL)isZero andSetTimeString:(NSString *)timeStr
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isZero = isZero;
        self.setTimeStr = timeStr;
        [self setTimePicker];
    }
    return  self;
}

- (void)setTimePicker
{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:now];
    NSArray *timeArr = [self.setTimeStr componentsSeparatedByString:@":"];

    self.nowHour = (self.setTimeStr == nil) ? [[dateString substringWithRange:NSMakeRange(8, 2)] intValue] : [timeArr[0] integerValue];
    self.nowMinute = (self.setTimeStr == nil) ? [[dateString substringWithRange:NSMakeRange(10, 2)] intValue] : [timeArr[1] integerValue];
    
    UILabel *hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(57, 18 + 170 / 3, 45, 15)];
    hourLabel.backgroundColor = [UIColor clearColor];
    hourLabel.text  = NSLocalizedString(@"Hour", nil);
    hourLabel.textColor = RGBA(30.0, 180.0, 240.0, 1.0);
    hourLabel.font = [UIFont systemFontOfSize:15];
    hourLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:hourLabel];
    
    UILabel *minuteLabel = [[UILabel alloc] initWithFrame:CGRectMake(157, 18 + 170 / 3, 55, 15)];
    minuteLabel.backgroundColor = [UIColor clearColor];
    minuteLabel.text  = NSLocalizedString(@"Minute", nil);
    minuteLabel.textColor = RGBA(30.0, 180.0, 240.0, 1.0);
    minuteLabel.font = [UIFont systemFontOfSize:15];
    minuteLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:minuteLabel];
    
    [self setHourPicker];
    [self setMinutePicker];
}

- (void)setHourPicker
{
    self.hourPicker = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, 60.0, 170.0)];
    [self.hourPicker setBackgroundColor:[UIColor clearColor]];
    [self.hourPicker setDelegate:self];
    [self.hourPicker setDataSource:self];
    [self.hourPicker setType:iCarouselTypeLinear];
    [self.hourPicker setVertical:YES];
    [self.hourPicker setClipsToBounds:YES];
    [self.hourPicker setDecelerationRate:.91f];
    
    if (self.isZero) {
        [self.hourPicker scrollToItemAtIndex:0 animated:NO];
    } else {
        [self.hourPicker scrollToItemAtIndex:self.nowHour animated:NO];
    }
    [self carouselCurrentItemIndexDidChange:self.hourPicker];
    [self addSubview:self.hourPicker];
}

- (void)setMinutePicker
{
    self.minutePicker = [[iCarousel alloc] initWithFrame:CGRectMake(100, 0, 60.0, 170.0)];
    [self.minutePicker setBackgroundColor:[UIColor clearColor]];
    [self.minutePicker setDelegate:self];
    [self.minutePicker setDataSource:self];
    [self.minutePicker setType:iCarouselTypeLinear];
    [self.minutePicker setVertical:YES];
    [self.minutePicker setClipsToBounds:YES];
    [self.minutePicker setDecelerationRate:.91f];
    
    if (self.isZero) {
        [self.minutePicker scrollToItemAtIndex:0 animated:NO];
    } else {
        [self.minutePicker scrollToItemAtIndex:self.nowMinute animated:NO];
    }
    [self carouselCurrentItemIndexDidChange:self.minutePicker];
    [self addSubview:self.minutePicker];
}

#pragma mark - iCarouselDataSource && iCarouseDelegate

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    int number = 0;
    if ([carousel isEqual:self.hourPicker]) {
        number = 24;
    }
    if ([carousel isEqual:self.minutePicker]) {
        number = 60;
    }
    
    long int index2 = carousel.currentItemIndex;
    NSMutableArray *itemArray = (NSMutableArray *)carousel.visibleItemViews;
    UILabel *label1;
    UILabel *label2;
    UILabel *label3;
    
    if (index2 == 0)
    {
        label1 = (UILabel *)[itemArray objectAtIndex:5];
        label2 = (UILabel *)[itemArray objectAtIndex:0];
        label3 = (UILabel *)[itemArray objectAtIndex:1];
    }
    else if (index2 == number - 1)
    {
        label1 = (UILabel *)[itemArray objectAtIndex:4];
        label2 = (UILabel *)[itemArray objectAtIndex:5];
        label3 = (UILabel *)[itemArray objectAtIndex:0];
    }
    else if (index2 == number - 2)
    {
        label1 = (UILabel *)[itemArray objectAtIndex:3];
        label2 = (UILabel *)[itemArray objectAtIndex:4];
        label3 = (UILabel *)[itemArray objectAtIndex:5];
    }
    else if (index2 == 1)
    {
        label1 = (UILabel *)[itemArray objectAtIndex:0];
        label2 = (UILabel *)[itemArray objectAtIndex:1];
        label3 = (UILabel *)[itemArray objectAtIndex:2];
        
    }
    else if (index2 == 2)
    {
        label1 = (UILabel *)[itemArray objectAtIndex:1];
        label2 = (UILabel *)[itemArray objectAtIndex:2];
        label3 = (UILabel *)[itemArray objectAtIndex:3];
    }
    else
    {
        label1 = (UILabel *)[itemArray objectAtIndex:2];
        label2 = (UILabel *)[itemArray objectAtIndex:3];
        label3 = (UILabel *)[itemArray objectAtIndex:4];
    }
    label1.backgroundColor = [UIColor clearColor];
    label2.backgroundColor = [UIColor clearColor];
    label3.backgroundColor = [UIColor clearColor];
    
    label1.textColor = RGBA(186.0, 186.0, 186.0, 1.0);
    label1.font = [UIFont systemFontOfSize:30.0f];
    label2.textColor = RGBA(30.0, 180.0, 240.0, 1.0);
    label2.font = [UIFont systemFontOfSize:45.0f];
    label3.textColor = RGBA(186.0, 186.0, 186.0, 1.0);
    label3.font = [UIFont systemFontOfSize:30.0f];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if (view == nil)
    {
        view = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, 60, 50)];
    }
    
    ((UILabel *)view).textAlignment = NSTextAlignmentCenter;
    ((UILabel *)view).font = [UIFont systemFontOfSize:30.0f];
    ((UILabel *)view).textColor = RGBA(186.0, 186.0, 186.0, 1.0);
    ((UILabel *)view).backgroundColor = [UIColor clearColor];
    
    ((UILabel *)view).text = [NSString stringWithFormat:@"%02lu", (unsigned long)index];
    return view;
}

//必须的方法
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    NSUInteger count = 0;
    if ([carousel isEqual:self.hourPicker])
    {
        count = 24;
    }
    else if ([carousel isEqual:self.minutePicker])
    {
        count = 60;
    }
    return count;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return value * 1.1;
    }
    // 首尾相连
    if (option == iCarouselOptionWrap)
    {
        return YES;
    }
    return value;
}

@end
