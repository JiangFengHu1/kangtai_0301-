//
//  EnergyInfoVC.m
//  kangtai
//
//  Created by 张群 on 14/10/30.
//  Copyright (c) 2014年 ohbuy. All rights reserved.
//

#import "EnergyInfoVC.h"
#import "PNPlot.h"
#import "LineChartView.h"
#import "UIViewController+MMDrawerController.h"

@interface EnergyInfoVC () <UIScrollViewDelegate>
{
    UIView *realTimeView;
    UIScrollView *kindScrollView;
    UIView *indicator;
    
    UIView *dayView;
    UIView *monthView;
    UIView *yearView;
    
    // 11.8
    UIView *curveView;
    
    //当前日期标签
    NSString *typeLabel;
    
    NSMutableArray *xDayArray;
    NSMutableArray *xMonthArray;
    NSMutableArray *xYearArray;

    NSMutableArray *dataDayArray;
    NSMutableArray *dataMonthArray;
    NSMutableArray *dataYearArray;
    
    // 上个月天数
    int dayNumberOfPreMonth;
    // 当月天数
    int dayNumberOfThisMonth;
    // 当天所在第几天
    int today;
    
    NSString *timeZone;
    UILabel *energyLabel;
    UILabel *iValueLabel;
    UILabel *voltageValueLabel;
    
    NSTimer *real_timeEnergyTimer;
}

@property (strong, nonatomic) LineChartView *dayChartView;
@property (strong, nonatomic) LineChartView *monthChartView;
@property (strong, nonatomic) LineChartView *yearChartView;

@end

@implementation EnergyInfoVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self refreshMonthData];
    [self refreshYearData];
}

#pragma mark - refreshMonthData
- (void)refreshMonthData
{
    NSString *unitStr = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@", self.macStr, self.macStr]];
    if (unitStr == nil) {
        unitStr = NSLocalizedString(@"unit_doller", nil);
    }
    NSString *priceStr = [[NSUserDefaults standardUserDefaults] objectForKey: self.macStr];
    if (priceStr == nil) {
        priceStr = @"0.00";
    }
    
    UIFont *font = [UIFont systemFontOfSize:25];
    CGSize size = CGSizeMake(kScreen_Width, 60);
    NSString *energyStr = [NSString stringWithFormat:@"%.2f KWH", totalMonth];
    NSString *costStr = [NSString stringWithFormat:@"%.2f %@", totalMonth * [priceStr floatValue], unitStr];
    CGSize energySize = [energyStr sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    CGSize costSize = [costStr sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel *tempLabel = (UILabel *)[self.view viewWithTag:11];
    tempLabel.frame = CGRectMake(kScreen_Width * 3 - 10 - energySize.width, (kScreen_Height == 480) ? 283 : 307, energySize.width, 60);
    tempLabel.text = energyStr;
    
    UILabel *tempLabel_ = (UILabel *)[self.view viewWithTag:21];
    tempLabel_.frame = CGRectMake(kScreen_Width * 3 - 10 - energySize.width, (kScreen_Height == 480) ? 313 : 355, costSize.width, 60);
    tempLabel_.text = costStr;
}

#pragma mark - refreshYearData
- (void)refreshYearData
{
    NSString *unitStr = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@", self.macStr, self.macStr]];
    if (unitStr == nil) {
        unitStr = NSLocalizedString(@"unit_doller", nil);
    }
    NSString *priceStr = [[NSUserDefaults standardUserDefaults] objectForKey: self.macStr];
    if (priceStr == nil) {
        priceStr = @"0.00";
    }
    
    UIFont *font = [UIFont systemFontOfSize:25];
    CGSize size = CGSizeMake(kScreen_Width, 60);
    NSString *energyStr = [NSString stringWithFormat:@"%.2f KWH", totalYear];
    NSString *costStr = [NSString stringWithFormat:@"%.2f %@", totalYear * [priceStr floatValue], unitStr];
    CGSize energySize = [energyStr sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    CGSize costSize = [costStr sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel *tempLabel = (UILabel *)[self.view viewWithTag:12];
    tempLabel.frame = CGRectMake(kScreen_Width * 4 - 10 - energySize.width, (kScreen_Height == 480) ? 283 : 307, energySize.width, 60);
    tempLabel.text = energyStr;
    
    UILabel *tempLabel_ = (UILabel *)[self.view viewWithTag:22];
    tempLabel_.frame = CGRectMake(kScreen_Width * 4 - 10 - energySize.width, (kScreen_Height == 480) ? 313 : 355, costSize.width, 60);
    tempLabel_.text = costStr;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.titlelab.text = NSLocalizedString(@"Energy Info", nil);
    [self.rightBut setBackgroundImage:[UIImage imageNamed:@"setting_normal.png"] forState:UIControlStateNormal];
    [self.rightBut setBackgroundImage:[UIImage imageNamed:@"setting_click.png"] forState:UIControlStateHighlighted];
    
    
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
    [MMProgressHUD showWithTitle:NSLocalizedString(@"Tips", nil) status:NSLocalizedString(@"Loading", nil)];
    [self performSelector:@selector(dismissHUD) withObject:nil afterDelay:2.5f];
    
    [self initVariable];
    [self initUI];
    [self showRealtimeEnergyDataView];
    [self initDayArray];
    [self initMonthArray];
    [self initYearArray];
}

#pragma mark - 初始化变量
- (void)initVariable
{
    //坐标轴
    _dayChartView=[[LineChartView alloc] init];
    _monthChartView=[[LineChartView alloc] init];
    _yearChartView=[[LineChartView alloc] init];
    xDayArray = [[NSMutableArray alloc] initWithCapacity:1];
    xMonthArray = [[NSMutableArray alloc] initWithCapacity:1];
    xYearArray = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray *tempArr = [[NSString stringWithFormat:@"%@",[NSTimeZone localTimeZone]] componentsSeparatedByString:@" "];
    timeZone = [[tempArr objectAtIndex:4] substringWithRange:NSMakeRange(1, 5)];
    
    dataDayArray = [NSMutableArray array];
    for (int i = 0; i < 24; i++) {
        [dataDayArray addObject:@"0"];
    }
    dataMonthArray = [NSMutableArray array];
    for (int i = 0; i < 30; i++) {
        [dataMonthArray addObject:@"0"];
    }
    dataYearArray = [NSMutableArray array];
    for (int i = 0; i < 12; i++) {
        [dataYearArray addObject:@"0"];
    }
}

#pragma mark - 初始化UI
- (void)initUI
{
    float height = (kScreen_Height == 480) ? 40 : 55;
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, barViewHeight, kScreen_Width, height)];
    topView.backgroundColor = RGBA(225, 225, 225, 1);
    [self.view addSubview:topView];
    
    indicator = [[UIView alloc] init];
    indicator.backgroundColor = RGBA(0, 160, 220, 1);
    indicator.tag = 100;
    
    NSArray *kindsArr = [NSArray arrayWithObjects:NSLocalizedString(@"Real-time", nil), NSLocalizedString(@"24H", nil), NSLocalizedString(@"Month", nil), NSLocalizedString(@"Year", nil), nil];
    for (int i = 0; i < 4; i++) {
        UIButton *chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        chooseBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        chooseBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [chooseBtn setTitle:kindsArr[i] forState:UIControlStateNormal];
        chooseBtn.frame = CGRectMake(kScreen_Width / 4 * i, barViewHeight, kScreen_Width / 4, height);
        if (i == 0) {
            chooseBtn.frame = CGRectMake(0, barViewHeight, kScreen_Width / 4 + 20, height);
            indicator.frame = CGRectMake(0, barViewHeight + height - 3, kScreen_Width / 4 + 20, 3);
            [chooseBtn setTitleColor:RGBA(0, 170, 230, 1) forState:UIControlStateNormal];
        } else {
            [chooseBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        if (i == 1) {
            chooseBtn.frame = CGRectMake(kScreen_Width / 4 + 20, barViewHeight, kScreen_Width / 4 - 20, height);
        }
        [chooseBtn addTarget:self action:@selector(chooseKind:) forControlEvents:UIControlEventTouchUpInside];
        chooseBtn.tag = 1000 + i;
        [self.view addSubview:chooseBtn];
    }
    [self.view addSubview:indicator];
    
    kindScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, barViewHeight + topView.frame.size.height, kScreen_Width, kScreen_Height - barViewHeight - topView.frame.size.height)];
    kindScrollView.delegate = self;
    kindScrollView.bounces = NO;
    kindScrollView.pagingEnabled = YES;
    kindScrollView.contentSize = CGSizeMake(kScreen_Width * 4, kScreen_Height - barViewHeight - topView.frame.size.height);
    kindScrollView.backgroundColor = [UIColor whiteColor];
    kindScrollView.showsHorizontalScrollIndicator = NO;
    kindScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:kindScrollView];
    
    NSDateFormatter * dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateformatter setFormatterBehavior:NSDateFormatterBehaviorDefault];
    
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * str = [dateformatter stringFromDate:[NSDate date]];
    
    NSArray *array = [str componentsSeparatedByString:@" "];
    NSString *time = [array objectAtIndex:0];
    NSArray *tempArr = [time componentsSeparatedByString:@"-"];
    int year = [[tempArr objectAtIndex:0] intValue];
    int month = [[tempArr objectAtIndex:1] intValue];
    today = [[tempArr objectAtIndex:2] intValue];
    NSArray *monthArr = @[@"1", @"2", @"3",@"4", @"5", @"6",@"7", @"8", @"9",@"10", @"11", @"12"];
    int index = (int)[monthArr indexOfObject:[NSString stringWithFormat:@"%d",month]];
    if (index == 0) {
        index = 12;
    }
    int preMonth = [[monthArr objectAtIndex:index - 1] intValue];
    
    dayNumberOfThisMonth = (int)[self getNumberOfMonth:[NSDate date]];
    
    if (preMonth == 1 || preMonth == 3 || preMonth == 5 || preMonth == 7 || preMonth == 8 || preMonth == 10 || preMonth == 12) {
        dayNumberOfPreMonth = 31;
    } else if (preMonth == 4 || preMonth == 6 || preMonth == 9 || preMonth == 11) {
        dayNumberOfPreMonth = 30;
    } else if (preMonth == 2) {
        if (year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)) {
            dayNumberOfPreMonth = 29;
        } else {
            dayNumberOfPreMonth = 28;
        }
    }
    
    CGSize size_30 = [Util sizeForText:NSLocalizedString(@"Last 30 days", nil) Font:15 forWidth:320];
    CGSize size_12 = [Util sizeForText:NSLocalizedString(@"Last 12 months", nil) Font:15 forWidth:320];
    CGFloat width = MAX(size_30.width, size_12.width) + 20;
    
    CGSize size_energy = [Util sizeForText:NSLocalizedString(@"Energy:", nil) Font:15 forWidth:320];
    CGSize size_cost = [Util sizeForText:NSLocalizedString(@"Cost:", nil) Font:15 forWidth:320];
    CGFloat width_ = MAX(size_energy.width, size_cost.width);
    
    for (int i = 1; i < 3; i++) {
        UILabel *lastLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width * (i + 1), (kScreen_Height == 480) ? 250 : 260,width, 35)];
        lastLabel.textAlignment = NSTextAlignmentCenter;
        lastLabel.backgroundColor = RGBA(234, 234, 234, 1);
        lastLabel.textColor = RGBA(170, 170, 170, 1);
        lastLabel.font = [UIFont systemFontOfSize:15];
        if (i == 1) {
            lastLabel.text = NSLocalizedString(@"Last 30 days", nil);
        }
        if (i == 2) {
            lastLabel.text = NSLocalizedString(@"Last 12 months", nil);
        }

        UILabel *consumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width * (i + 1) + 15, (kScreen_Height == 480) ? 295 : 320, width_, 35)];
        consumeLabel.backgroundColor = [UIColor clearColor];
        consumeLabel.textColor = RGBA(85, 85, 85, 1);
        consumeLabel.font = [UIFont systemFontOfSize:15];
        consumeLabel.text = NSLocalizedString(@"Energy:", nil);
        
        UILabel *costLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width * (i + 1) + 15, (kScreen_Height == 480) ? 325 : 370, width_, 35)];
        costLabel.backgroundColor = [UIColor clearColor];
        costLabel.textColor = RGBA(85, 85, 85, 1);
        costLabel.font = [UIFont systemFontOfSize:15];
        costLabel.text = NSLocalizedString(@"Cost:", nil);
        
        UILabel *consumeValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width * (i + 1) + width_ + 15, (kScreen_Height == 480) ? 283 : 307, kScreen_Width - width_ - 30, 60)];
        consumeValueLabel.textAlignment = NSTextAlignmentRight;
        consumeValueLabel.tag = 10 + i;
        consumeValueLabel.backgroundColor = [UIColor clearColor];
        consumeValueLabel.textColor = RGBA(0, 164, 228, 1);
        consumeValueLabel.font = [UIFont systemFontOfSize:25];
        
        UILabel *costValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width * (i + 1) + width_ + 15, (kScreen_Height == 480) ? 313 : 355, kScreen_Width - width_ - 30, 60)];
        costValueLabel.tag = 20 + i;
        costValueLabel.backgroundColor = [UIColor clearColor];
        costValueLabel.textColor = RGBA(0, 164, 228, 1);
        costValueLabel.font = [UIFont systemFontOfSize:25];
        
        [kindScrollView addSubview:lastLabel];
        [kindScrollView addSubview:consumeLabel];
        [kindScrollView addSubview:costLabel];
        [kindScrollView addSubview:consumeValueLabel];
        [kindScrollView addSubview:costValueLabel];
    }
    
    /*dataView*/
    dayView = [[UIView alloc] initWithFrame:CGRectMake(kScreen_Width,0, kScreen_Width, 235)];
    [kindScrollView addSubview:dayView];
    
    monthView = [[UIView alloc] initWithFrame:CGRectMake(kScreen_Width * 2,0, kScreen_Width, 235)];
    [kindScrollView addSubview:monthView];
    
    yearView = [[UIView alloc] initWithFrame:CGRectMake(kScreen_Width * 3, 0, kScreen_Width, 235)];
    [kindScrollView addSubview:yearView];
    
    [self updateRealtimeDataEveryFiveSeconds];
    real_timeEnergyTimer = [NSTimer scheduledTimerWithTimeInterval:7.f target:self selector:@selector(updateRealtimeDataEveryFiveSeconds) userInfo:nil repeats:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getEnergyData];
    });
}

#pragma mark - initDayArray
- (void)initDayArray
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [calendar components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    NSMutableArray *textArray = [[NSMutableArray alloc] init];
    for (int i=0; i<24; i++)
    {
        NSString *string;
        int hour = (int)([comps hour] + 24 - i);
        int hour_ = hour % 24 - 1;
        if (hour % 24 == 0) {
            hour_ = 23;
        }
        string = [NSString stringWithFormat:@"%d:00", hour % 24];
        [textArray insertObject:string atIndex:0];
    }
    [textArray insertObject:@"" atIndex:0];
    xDayArray = textArray;
    
    [self showEnergyDayView];
}

#pragma mark - initMonthArray
- (void)initMonthArray
{
    NSMutableArray *dayArray = [[NSMutableArray alloc] init];
    NSMutableArray *dayArr = [[NSMutableArray alloc] init];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSMutableArray *tempArray_ = [[NSMutableArray alloc] init];
    
    if (today == dayNumberOfThisMonth) {
        for (int i = 1; i <= dayNumberOfThisMonth; i++) {
            [dayArr addObject:[NSString stringWithFormat:@"%dth",i]];
            [tempArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        if (dayNumberOfThisMonth == 31) {
            for (int i = 1; i < 31; i ++) {
                [dayArray addObject:dayArr[i]];
                [tempArray_ addObject:tempArray[i]];
            }
        }
        if (dayNumberOfThisMonth == 30) {
            for (int i = 0; i < 30; i ++) {
                [dayArray addObject:dayArr[i]];
                [tempArray_ addObject:tempArray[i]];
            }
        }
        if (dayNumberOfThisMonth < 30) {
            for (int i = 0; i < dayNumberOfThisMonth; i ++) {
                [dayArray addObject:dayArr[i]];
                [tempArray_ addObject:tempArray[i]];
            }
            if (dayNumberOfThisMonth == 29) {
                [dayArray insertObject:@"31th" atIndex:0];
                [tempArray_ insertObject:@"31th" atIndex:0];
            }
            if (dayNumberOfThisMonth == 28) {
                [dayArray insertObject:@"31th" atIndex:0];
                [tempArray_ insertObject:@"31th" atIndex:0];
                [dayArray insertObject:@"30th" atIndex:0];
                [tempArray_ insertObject:@"31th" atIndex:0];
            }
        }
    }
    if (today != dayNumberOfThisMonth) {
        if (today == 30) {
            for (int i = 1; i <= 30; i++) {
                [dayArray addObject:[NSString stringWithFormat:@"%dth",i]];
                [tempArray_ addObject:[NSString stringWithFormat:@"%d",i]];
            }
        } else {
            
            for (int i = 1; i <= dayNumberOfPreMonth; i++) {
                [dayArr addObject:[NSString stringWithFormat:@"%dth",i]];
                [tempArray addObject:[NSString stringWithFormat:@"%d",i]];
            }
            for (int i = today; i < dayNumberOfPreMonth; i++) {
                [dayArray addObject:[dayArr objectAtIndex:i]];
                [tempArray_ addObject:[tempArray objectAtIndex:i]];
            }
            for (int i = 0; i < today; i++) {
                [dayArray addObject:dayArr[i]];
                [tempArray_ addObject:tempArray[i]];
            }
            if (dayNumberOfPreMonth == 31) {
                [dayArray removeObjectAtIndex:0];
                [tempArray_ removeObjectAtIndex:0];
            }
            
            if (today == 1) {
                if (dayNumberOfPreMonth == 29) {
                    [dayArray insertObject:@"1th" atIndex:0];
                    [tempArray_ insertObject:@"1" atIndex:0];
                }
                if (dayNumberOfPreMonth == 28) {
                    [dayArray insertObject:@"1th" atIndex:0];
                    [dayArray insertObject:@"31th" atIndex:0];
                    [tempArray_ insertObject:@"1" atIndex:0];
                    [tempArray_ insertObject:@"31" atIndex:0];
                }
            }
            if (today == 2) {
                if (dayNumberOfPreMonth == 29) {
                    [dayArray insertObject:@"2th" atIndex:0];
                    [tempArray_ insertObject:@"2th" atIndex:0];
                }
                if (dayNumberOfPreMonth == 28) {
                    [dayArray insertObject:@"2th" atIndex:0];
                    [dayArray insertObject:@"1th" atIndex:0];
                    [tempArray_ insertObject:@"2" atIndex:0];
                    [tempArray_ insertObject:@"1" atIndex:0];
                }
            }
            if (today > 2) {
                
                if (dayNumberOfPreMonth == 29) {
                    [dayArray insertObject:[dayArr objectAtIndex:today - 1] atIndex:0];
                    [tempArray_ insertObject:[tempArray objectAtIndex:today - 1] atIndex:0];
                }
                if (dayNumberOfPreMonth == 28) {
                    [dayArray insertObject:[dayArr objectAtIndex:today - 1] atIndex:0];
                    [dayArray insertObject:[dayArr objectAtIndex:today - 2] atIndex:0];
                    [tempArray_ insertObject:[tempArray objectAtIndex:today - 1] atIndex:0];
                    [tempArray_ insertObject:[tempArray objectAtIndex:today - 2] atIndex:0];
                }
            }
        }
    }
    [dayArray insertObject:@"" atIndex:0];
    
    xMonthArray = dayArray;
    
    [self showEnergyMonthView];
}

#pragma mark - initYearArray
- (void)initYearArray
{
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    comps = [calendar components:unitFlags fromDate:date];
    
    //横坐标
    NSMutableArray *dayArray = [[NSMutableArray alloc] init];
    //保存每个月有多少天
    NSMutableArray *dayInMonth = [[NSMutableArray alloc] init];
    //  定义一个NSDateComponents对象，设置一个时间点
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponentsForDate = [[NSDateComponents alloc] init];
    NSDate *dateFromDateComponentsForDate;
    for (int i=0; i<12; i++)
    {
        NSString *string=@"";
        int countDayInMonth=0;
        int weekDay = (int)([comps month]+i+1);
        if(weekDay>12)
        {
            weekDay=weekDay-12;
            [dateComponentsForDate setYear:[comps year]];
        }
        else
        {
            [dateComponentsForDate setYear:[comps year]-1];
        }
        [dateComponentsForDate setMonth:weekDay];
        dateFromDateComponentsForDate= [greCalendar dateFromComponents:dateComponentsForDate];
        //计算每个月有多少天
        countDayInMonth=(int)[self getNumberOfMonth:dateFromDateComponentsForDate];
        string=[self turnToEnglishMonth:weekDay];
        [dayArray addObject:string];
        [tempArr addObject:[NSString stringWithFormat:@"%d", weekDay]];
        [dayInMonth addObject:[NSNumber numberWithInt:countDayInMonth]];
    }
    [dayArray insertObject:@"" atIndex:0];
    xYearArray = dayArray;
    

    [self showEnergyYearView];
}

#pragma mark - dismissHUD
- (void)dismissHUD
{
    [MMProgressHUD dismiss];
}

#pragma mark - updateRealtimeDataEveryFiveSeconds
- (void)updateRealtimeDataEveryFiveSeconds
{
    [self checkDeviceWattInfo];
    [self performSelector:@selector(updateRealtimeData) withObject:nil afterDelay:2.f];
}

#pragma mark - 检查实时电量
- (void)checkDeviceWattInfo
{
    Device *device = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:self.macStr];
    
    [DeviceManagerInstance getQueryDeviceWattInfoWith:device.mac Withhost:device.host key:device.key With:device.localContent];
}

#pragma mark - chooseBtn method
- (void)chooseKind:(UIButton *)btn
{
    float height = (kScreen_Height == 480) ? 40 : 55;
    
    for (int i = 0; i < 4; i++) {
        UIButton *chooseBtn = (UIButton *)[self.view viewWithTag:1000 + i];
        if (i == btn.tag - 1000) {
            [chooseBtn setTitleColor:RGBA(0, 170, 230, 1) forState:UIControlStateNormal];
            [indicator setFrame:CGRectMake(btn.frame.origin.x, barViewHeight + height - 3, btn.frame.size.width, 3)];
            [kindScrollView setContentOffset:CGPointMake(kScreen_Width * i, 0) animated:YES];
        } else {
            [chooseBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - getEnergyData
- (void)getEnergyData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self checkDeviceWattInfo];
        [self get24HEnergyInfo];
        [self getMonthEnergyInfo];
        [self getYearEnergyInfo];
    });
}

#pragma mark - Show real-time energy data view
- (void)showRealtimeEnergyDataView
{
    realTimeView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - barViewHeight - ((kScreen_Height == 480) ? 40 : 55))];
    realTimeView.backgroundColor = [UIColor whiteColor];
    
    UILabel *realLalel = [[UILabel alloc] initWithFrame:CGRectMake(20, 25 * heightScale, kScreen_Width - 20, 20)];
    realLalel.backgroundColor = [UIColor clearColor];
    realLalel.text = NSLocalizedString(@"Real time power", nil);
    realLalel.textAlignment = NSTextAlignmentLeft;
    realLalel.textColor = RGBA(85, 85, 85, 1);
    realLalel.font = [UIFont systemFontOfSize:16];
    [realTimeView addSubview:realLalel];

    UIFont *font = [UIFont systemFontOfSize:25];
    energyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40 * heightScale + 20, 250, 30)];
    energyLabel.backgroundColor = [UIColor clearColor];
    energyLabel.textColor = RGBA(0, 170, 230, 1);
    energyLabel.textAlignment = NSTextAlignmentLeft;
    energyLabel.font = font;
    energyLabel.text = @"0.0 W";
    [realTimeView addSubview:energyLabel];
    
    UIView *firstLine = [[UIView alloc] initWithFrame:CGRectMake(0, 60 * heightScale + 50, kScreen_Width, 1)];
    firstLine.backgroundColor = RGBA(210, 210, 210, 1);
    [realTimeView addSubview:firstLine];
    
    UILabel *currentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80 * heightScale + 50, kScreen_Width - 20, 30)];
    currentLabel.backgroundColor = [UIColor clearColor];
    currentLabel.text = NSLocalizedString(@"Electric current", nil);
    currentLabel.textAlignment = NSTextAlignmentLeft;
    currentLabel.textColor = RGBA(85, 85, 85, 1);
    currentLabel.font = [UIFont systemFontOfSize:16];
    [realTimeView addSubview:currentLabel];

    iValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100 * heightScale + 70, 250, 30)];
    iValueLabel.backgroundColor = [UIColor clearColor];
    iValueLabel.textColor = RGBA(0, 170, 230, 1);
    iValueLabel.text = @"0.00 A";
    iValueLabel.textAlignment = NSTextAlignmentLeft;
    iValueLabel.font = font;
    [realTimeView addSubview:iValueLabel];

    UIView *secondLine = [[UIView alloc] initWithFrame:CGRectMake(0,  130 * heightScale + 90, kScreen_Width, 1)];
    secondLine.backgroundColor = RGBA(210, 210, 210, 1);
    [realTimeView addSubview:secondLine];
    
    UILabel *voltageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 150 * heightScale + 90, kScreen_Width - 20, 30)];
    voltageLabel.backgroundColor = [UIColor clearColor];
    voltageLabel.text = NSLocalizedString(@"Voltage", nil);
    voltageLabel.textAlignment = NSTextAlignmentLeft;
    voltageLabel.textColor = RGBA(85, 85, 85, 1);
    voltageLabel.font = [UIFont systemFontOfSize:16];
    [realTimeView addSubview:voltageLabel];
    
    voltageValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 160 * heightScale + 120, kScreen_Width - 20, 30)];
    voltageValueLabel.backgroundColor = [UIColor clearColor];
    voltageValueLabel.textColor = RGBA(0, 170, 230, 1);
    voltageValueLabel.text = @"0 V";
    voltageValueLabel.textAlignment = NSTextAlignmentLeft;
    voltageValueLabel.font = font;
    [realTimeView addSubview:voltageValueLabel];
    
    [kindScrollView addSubview:realTimeView];
}

#pragma mark- update realtime data
- (void)updateRealtimeData
{
    NSMutableArray *wattArr = [[NSUserDefaults standardUserDefaults] objectForKey: WATT_INFO];
    NSDictionary *wattDic = nil;
    NSData *iData;
    NSData *vData;
    NSData *pData;
    NSString *iStr;
    NSString *vStr;
    NSString *pStr;
    
    if (wattArr.count != 0) {
        wattDic = wattArr[0];
        iData = wattDic[@"elcCurrent"];
        vData = wattDic[@"voltage"];
        pData = wattDic[@"power"];
        iStr = [[NSString stringWithFormat:@"%@",iData] substringWithRange:NSMakeRange(1, 4)];
        vStr = [[NSString stringWithFormat:@"%@",vData] substringWithRange:NSMakeRange(1, 4)];
        pStr = [[NSString stringWithFormat:@"%@",pData] substringWithRange:NSMakeRange(1, 8)];
    } else {
        iStr = @"0000";
        vStr = @"0000";
        pStr = @"00000000";
    }

    energyLabel.text = [NSString stringWithFormat:@"%d.%@ W",[[pStr substringWithRange:NSMakeRange(0, 7)] intValue], [pStr substringWithRange:NSMakeRange(7, 1)]];
    iValueLabel.text = [NSString stringWithFormat:@"%d.%@ A",[[iStr substringWithRange:NSMakeRange(0, 2)] intValue], [iStr substringWithRange:NSMakeRange(2, 2)]];
    voltageValueLabel.text = [NSString stringWithFormat:@"%d V",[vStr intValue]];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:WATT_INFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Show energy day view
- (void)showEnergyDayView
{
    for (UIView *view in [dayView subviews])
    {
        [view removeFromSuperview];
    }
    _dayChartView = nil;
    if([xDayArray count]<=0 || [dataDayArray count]<=0)
    {
        return;
    }
    
    //垂直条
    float verticalBar=7.f;
    //scrollView
    UIScrollView *scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(8.75, 0, kScreen_Width, 235)];
    //背景颜色
    [scrollView setBackgroundColor:[UIColor clearColor]];
    // 绘图
    scrollView.bounces = NO;
    scrollView.alwaysBounceHorizontal = YES;
    
    _dayChartView=[[LineChartView alloc] initWithFrame:CGRectMake(0, 0, 41*49, 200)WithLabFrame:  CGRectMake(0, 0, 70, 20) WithName:@""];
    _dayChartView.chosenType = 0;
    
    scrollView.frame=  CGRectMake(0, 0, kScreen_Width, 235);
    _dayChartView.frame = CGRectMake(0, 0, 41*49, 235);
    
    [dayView addSubview:scrollView];
    scrollView.contentOffset = CGPointMake(41*49/2, 0);
    
    //长度
    [_dayChartView setMaxWidth:_dayChartView.frame.size.width];
    //高度
    [_dayChartView setMaxHeight:_dayChartView.frame.size.height];
    //垂直线
    [_dayChartView setVInterval:(235-35)/verticalBar];
    //水平线
    [_dayChartView setHInterval:40];
    
    
    [_dayChartView setBackgroundColor:[UIColor whiteColor]];
    dayView.backgroundColor=[UIColor whiteColor];
    
    
    //最大数据
    float maxData=0;
    //取得最大的能耗
    for (int i=0; i<dataDayArray.count; i++)
    {
        float tmp=[[dataDayArray objectAtIndex:i] floatValue];
        if(maxData < tmp)
        {
            maxData = tmp;
        }
    }
    
    [_dayChartView setHIntervalData:maxData / 5.f];
    maxData = maxData / 5.f;
    
    //竖轴
    NSMutableArray *vArr = [[NSMutableArray alloc]init];
    [vArr removeAllObjects];
    for (int i=0; i<verticalBar; i++) {
        if(maxData > 0)
        {
            if(i==0)
            {
                [vArr addObject:[NSString stringWithFormat:@"0.0"]];
            }
            else
            {
                
                if(i * maxData > 100)
                    [vArr addObject:[NSString stringWithFormat:@"%d",(int)(i * maxData)]];
                else
                    [vArr addObject:[NSString stringWithFormat:@"%.1f",i * maxData]];
            }
        }
        else
        {
            [vArr addObject:[NSString stringWithFormat:@"0.0"]];
        }
    }
    
    //坐标参数
    [_dayChartView setHDesc:xDayArray];
    [_dayChartView setVDesc:vArr];
    PNPlot *plot1 = [[PNPlot alloc] init];
    plot1.plottingValues = dataDayArray;
    plot1.lineWidth = 1.f;
#pragma mark- 曲线图颜色
    plot1.lineColor = [UIColor grayColor];
    plot1.heightLineColor = RGBA(0, 160, 230, 1);
    [_dayChartView addPlot:plot1];
    [scrollView addSubview:_dayChartView];
    
    int height_H = 40;
    [_dayChartView setHInterval:40];
    [scrollView setContentSize:CGSizeMake(40*[xDayArray count]+30, scrollView.frame.size.height)];
    
    UIView *view_v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, height_H, scrollView.frame.size.height)];
    view_v.backgroundColor = [UIColor whiteColor];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(height_H, 30, 1.4, 175)];
    line.backgroundColor = RGBA(15, 175, 230, .65f);
    [view_v addSubview:line];
    
    UILabel *unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 40, 25)];
    unitLabel.text = @"W";
    unitLabel.backgroundColor = [UIColor clearColor];
    unitLabel.textAlignment = NSTextAlignmentRight;
    unitLabel.textColor = RGBA(0, 160, 230, 1);
    unitLabel.font = [UIFont systemFontOfSize:14];
    [view_v addSubview:unitLabel];

    [dayView addSubview:view_v];
    
    for (int i=0; i<vArr.count - 1; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 165-i *25, height_H, 20)];
        
        [_dayChartView setVInterval:(235-35)/6.5];
        
        view_v.frame = CGRectMake(0, 0, height_H, 235);
        label.frame = CGRectMake(0, 187-i*30, height_H, 30);
        if (i > 1 && i < 4) {
            label.frame = CGRectMake(0, 186-i*30, height_H, 30);
        } else if (i == 4) {
            label.frame = CGRectMake(0, 185-i*30, height_H, 30);
        } else if (i == 5) {
            label.frame = CGRectMake(0, 183-i*30, height_H, 30);
        }
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:RGBA(0, 160, 230, 1)];
        [label setFont:[UIFont systemFontOfSize:12.f]];
        label.tag = 110+ i;
        
        [label setText:[vArr objectAtIndex:i]];

        [view_v addSubview:label];
    }
}


#pragma mark - Show energy month view.
- (void)showEnergyMonthView
{
    static int i = 1;
    
    NSLog(@"=== 次数 == %d === array == %@ %@ ==", i, xMonthArray, dataMonthArray);
    
    i++;
    
    
    for (UIView *view in [monthView subviews])
    {
        [view removeFromSuperview];
    }
    _monthChartView = nil;
    if([xMonthArray count]<=0 || [dataMonthArray count]<=0)
    {
        return;
    }
    
    //垂直条
    float verticalBar=7.f;

    //scrollView
    UIScrollView *scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 235)];
    //背景颜色
    [scrollView setBackgroundColor:[UIColor clearColor]];
    // 绘图
    scrollView.bounces = NO;
    scrollView.alwaysBounceHorizontal = YES;
    
    _monthChartView =[[LineChartView alloc] initWithFrame:CGRectMake(0, 0, 41*49, 200)WithLabFrame:  CGRectMake(0, 0, 70, 20) WithName:@""];
    _monthChartView.chosenType = 2;
    
    scrollView.frame=  CGRectMake(0, 0, kScreen_Width, 235);
    _monthChartView.frame = CGRectMake(0, 0, 41*49, 235);
    
    [monthView addSubview:scrollView];
    scrollView.contentOffset = CGPointMake(41*49/2, 0);
    
    //长度
    [_monthChartView setMaxWidth:_monthChartView.frame.size.width];
    //高度
    [_monthChartView setMaxHeight:_monthChartView.frame.size.height];
    //垂直线
    [_monthChartView setVInterval:(235-35)/verticalBar];
    //水平线
    [_monthChartView setHInterval:40];
    [_monthChartView setBackgroundColor:[UIColor whiteColor]];
    monthView.backgroundColor=[UIColor whiteColor];
    
    //最大数据
    float maxData = 0;
    float totalData = 0;
    //取得最大的能耗
    for (int i=0; i<dataMonthArray.count; i++)
    {
        float tmp=[[dataMonthArray objectAtIndex:i] floatValue];
        if(maxData < tmp)
        {
            maxData = tmp;
        }
        if (tmp > 0) {
            totalData = totalData + tmp;
        }
    }
    
    totalMonth = totalData;
    
    [_monthChartView setHIntervalData:maxData / 5.f];
    maxData = maxData / 5.f;
    
    NSString *unitStr = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@", self.macStr, self.macStr]];
    if (unitStr == nil) {
        unitStr = NSLocalizedString(@"unit_doller", nil);
    }
    NSString *priceStr = [[NSUserDefaults standardUserDefaults] objectForKey: self.macStr];
    if (priceStr == nil) {
        priceStr = @"0.00";
    }
    
    UIFont *font = [UIFont systemFontOfSize:25];
    CGSize size = CGSizeMake(kScreen_Width, 60);
    NSString *energyStr = [NSString stringWithFormat:@"%.2f KWH", totalData];
    NSString *costStr = [NSString stringWithFormat:@"%.2f %@", totalData * [priceStr floatValue], unitStr];
    CGSize energySize = [energyStr sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    CGSize costSize = [costStr sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel *tempLabel = (UILabel *)[self.view viewWithTag:11];
    tempLabel.frame = CGRectMake(kScreen_Width * 3 - 10 - energySize.width, (kScreen_Height == 480) ? 283 : 307, energySize.width, 60);
    tempLabel.text = energyStr;
    
    UILabel *tempLabel_ = (UILabel *)[self.view viewWithTag:21];
    tempLabel_.frame = CGRectMake(kScreen_Width * 3 - 10 - energySize.width, (kScreen_Height == 480) ? 313 : 355, costSize.width, 60);
    tempLabel_.text = costStr;

    //竖轴
    NSMutableArray *vArr = [[NSMutableArray alloc]init];
    [vArr removeAllObjects];
    for (int i=0; i<verticalBar; i++) {
        if(maxData > 0)
        {
            if(i==0)
            {
                [vArr addObject:[NSString stringWithFormat:@"0.0"]];
            }
            else
            {
                
                if(i * maxData > 100)
                    [vArr addObject:[NSString stringWithFormat:@"%d",(int)(i * maxData)]];
                else
                    [vArr addObject:[NSString stringWithFormat:@"%.1f",i * maxData]];
            }
        }
        else
        {
            [vArr addObject:[NSString stringWithFormat:@"0.0"]];
        }
    }
    
    //坐标参数
    [_monthChartView setHDesc:xMonthArray];
    [_monthChartView setVDesc:vArr];
    PNPlot *plot1 = [[PNPlot alloc] init];
    plot1.plottingValues = dataMonthArray;
    plot1.lineWidth = 1.f;
#pragma mark- 曲线图颜色
    plot1.lineColor = [UIColor grayColor];
    plot1.heightLineColor = RGBA(0, 160, 230, 1);
    [self.monthChartView addPlot:plot1];
    [scrollView addSubview:_monthChartView];
    
    int height_H = 40;
    [_monthChartView setHInterval:40];
    [scrollView setContentSize:CGSizeMake(40*[xMonthArray count]+30, scrollView.frame.size.height)];
    
    UIView *view_v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, height_H, 235)];
    view_v.backgroundColor = [UIColor whiteColor];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(height_H, 30, 1.4, 175)];
    line.backgroundColor = RGBA(15, 175, 230, .65f);
    [view_v addSubview:line];
    
    UILabel *unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 40, 25)];
    unitLabel.text = @"KWH";
    unitLabel.backgroundColor = [UIColor clearColor];
    unitLabel.textAlignment = NSTextAlignmentRight;
    unitLabel.textColor = RGBA(0, 160, 230, 1);
    unitLabel.font = [UIFont systemFontOfSize:14];
    [view_v addSubview:unitLabel];
    
    [monthView addSubview:view_v];
    
    for (int i=0; i<vArr.count - 1; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 165-i *25, height_H, 20)];
        [_monthChartView setVInterval:(235-35)/6.5];
        
        view_v.frame = CGRectMake(0, 0, height_H, 235);
        label.frame = CGRectMake(0, 187-i*30, height_H, 30);
        if (i > 1 && i < 4) {
            label.frame = CGRectMake(0, 186-i*30, height_H, 30);
        } else if (i == 4) {
            label.frame = CGRectMake(0, 185-i*30, height_H, 30);
        } else if (i == 5) {
            label.frame = CGRectMake(0, 183-i*30, height_H, 30);
        }

        [label setTextAlignment:NSTextAlignmentCenter];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:RGBA(0, 160, 230, 1)];
        [label setFont:[UIFont systemFontOfSize:12.f]];
        label.tag = 110+ i;
        
        [label setText:[vArr objectAtIndex:i]];

        [view_v addSubview:label];
    }
}

#pragma mark - Show energy year view.
- (void)showEnergyYearView
{
    for (UIView *view in [yearView subviews])
    {
        [view removeFromSuperview];
    }
    _yearChartView = nil;
    if([xYearArray count]<=0 || [dataYearArray count]<=0)
    {
        return;
    }
    
    //垂直条
    float verticalBar=7.f;
    
    //scrollView
    UIScrollView *scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 235)];
    //背景颜色
    [scrollView setBackgroundColor:[UIColor clearColor]];
    // 绘图
    scrollView.bounces = NO;
    scrollView.alwaysBounceHorizontal = YES;
    
    _yearChartView=[[LineChartView alloc] initWithFrame:CGRectMake(0, 0, 41*49, 200)WithLabFrame:  CGRectMake(0, 0, 70, 20) WithName:@""];
    _yearChartView.chosenType = 3;
    
    scrollView.frame=  CGRectMake(0, 0, kScreen_Width, 235);
    _yearChartView.frame = CGRectMake(0, 0, 41*49, 235);
    
    [yearView addSubview:scrollView];
    scrollView.contentOffset = CGPointMake(41*49/2, 0);

    //长度
    [_yearChartView setMaxWidth:_yearChartView.frame.size.width];
    //高度
    [_yearChartView setMaxHeight:_yearChartView.frame.size.height];
    //垂直线
    [_yearChartView setVInterval:(235-35)/verticalBar];
    //水平线
    [_yearChartView setHInterval:40];
    
    [_yearChartView setBackgroundColor:[UIColor whiteColor]];
    yearView.backgroundColor=[UIColor whiteColor];
    
    
    //最大数据
    float maxData=0;
    float totalData = 0;
    
    
    //取得最大的能耗
    for (int i=0; i<dataYearArray.count; i++)
    {
        float tmp=[[dataYearArray objectAtIndex:i] floatValue];
        if(maxData < tmp)
        {
            maxData = tmp;
        }
        if (tmp > 0) {
            totalData = totalData + tmp;
        }
    }
    
    totalYear = totalData;
    
    [_yearChartView setHIntervalData:maxData / 5.f];
    maxData = maxData / 5.f;
    
    NSString *unitStr = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@", self.macStr, self.macStr]];
    if (unitStr == nil) {
        unitStr = NSLocalizedString(@"unit_doller", nil);
    }
    NSString *priceStr = [[NSUserDefaults standardUserDefaults] objectForKey: self.macStr];
    if (priceStr == nil) {
        priceStr = @"0.00";
    }
    
    UIFont *font = [UIFont systemFontOfSize:25];
    CGSize size = CGSizeMake(kScreen_Width, 60);
    NSString *energyStr = [NSString stringWithFormat:@"%.2f KWH", totalData];
    NSString *costStr = [NSString stringWithFormat:@"%.2f %@", totalData * [priceStr floatValue], unitStr];
    CGSize energySize = [energyStr sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    CGSize costSize = [costStr sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel *tempLabel = (UILabel *)[self.view viewWithTag:12];
    tempLabel.frame = CGRectMake(kScreen_Width * 4 - 10 - energySize.width, (kScreen_Height == 480) ? 283 : 307, energySize.width, 60);
    tempLabel.text = energyStr;
    
    UILabel *tempLabel_ = (UILabel *)[self.view viewWithTag:22];
    tempLabel_.frame = CGRectMake(kScreen_Width * 4 - 10 - energySize.width, (kScreen_Height == 480) ? 313 : 355, costSize.width, 60);
    tempLabel_.text = costStr;
    
    //竖轴
    NSMutableArray *vArr = [[NSMutableArray alloc]init];
    [vArr removeAllObjects];
    for (int i=0; i<verticalBar; i++) {
        if(maxData > 0)
        {
            if(i==0)
            {
                [vArr addObject:[NSString stringWithFormat:@"0.0"]];
            }
            else
            {
                
                if(i * maxData > 100)
                    [vArr addObject:[NSString stringWithFormat:@"%d",(int)(i * maxData)]];
                else
                    [vArr addObject:[NSString stringWithFormat:@"%.1f",i * maxData]];
            }
        }
        else
        {
            [vArr addObject:[NSString stringWithFormat:@"0.0"]];
        }
    }
    
    //坐标参数
    [_yearChartView setHDesc:xYearArray];
    [_yearChartView setVDesc:vArr];
    PNPlot *plot1 = [[PNPlot alloc] init];
    plot1.plottingValues = dataYearArray;
    plot1.lineWidth = 1.f;
#pragma mark- 曲线图颜色
    plot1.lineColor = [UIColor grayColor];
    plot1.heightLineColor = RGBA(0, 160, 230, 1);
    [_yearChartView addPlot:plot1];
    [scrollView addSubview:_yearChartView];
    
    int height_H = 40;
    [_yearChartView setHInterval:40];
    [scrollView setContentSize:CGSizeMake(40*[xYearArray count]+30, scrollView.frame.size.height)];
    
    UIView *view_v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, height_H, 235)];
    view_v.backgroundColor = [UIColor whiteColor];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(height_H, 30, 1.4, 175)];
    line.backgroundColor = RGBA(15, 175, 230, .65f);
    [view_v addSubview:line];
    
    UILabel *unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 40, 25)];
    unitLabel.text = @"KWH";
    unitLabel.backgroundColor = [UIColor clearColor];
    unitLabel.textAlignment = NSTextAlignmentRight;
    unitLabel.textColor = RGBA(0, 160, 230, 1);
    unitLabel.font = [UIFont systemFontOfSize:14];
    [view_v addSubview:unitLabel];
    
    [yearView addSubview:view_v];
    
    for (int i=0; i<vArr.count - 1; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 165-i *25, height_H, 20)];
        
        [_yearChartView setVInterval:(235-35)/6.5];
        
        view_v.frame = CGRectMake(0, 0, height_H, 235);
        label.frame = CGRectMake(0, 187-i*30, height_H, 30);
        if (i > 1 && i < 4) {
            label.frame = CGRectMake(0, 186-i*30, height_H, 30);
        } else if (i == 4) {
            label.frame = CGRectMake(0, 185-i*30, height_H, 30);
        } else if (i == 5) {
            label.frame = CGRectMake(0, 183-i*30, height_H, 30);
        }

        [label setTextAlignment:NSTextAlignmentCenter];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:RGBA(0, 160, 230, 1)];
        [label setFont:[UIFont systemFontOfSize:12.f]];
        label.tag = 110+ i;
        
        [label setText:[vArr objectAtIndex:i]];
        [view_v addSubview:label];
    }
}

#pragma mark -计算每个月有多少天
-(NSInteger)getNumberOfMonth:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSInteger numOfdayInMonth = range.length;
    return numOfdayInMonth;
}

#pragma mark - 根据index返回英文月份
-(NSString *)turnToEnglishMonth:(int)index
{
    NSString *string=@"";
    if(index == 0)
    {
        string=NSLocalizedString(@"Dec", nil);
    }
    switch(index)
    {
        case 1:
            string=NSLocalizedString(@"Jan", nil);
            break;
        case 2:
            string=NSLocalizedString(@"Feb", nil);
            break;
        case 3:
            string=NSLocalizedString(@"Mar", nil);
            break;
        case 4:
            string=NSLocalizedString(@"Apr", nil);
            break;
        case 5:
            string=NSLocalizedString(@"May", nil);
            break;
        case 6:
            string=NSLocalizedString(@"Jun", nil);
            break;
        case 7:
            string=NSLocalizedString(@"Jul", nil);
            break;
        case 8:
            string=NSLocalizedString(@"Aug", nil);
            break;
        case 9:
            string=NSLocalizedString(@"Sep", nil);
            break;
        case 10:
            string=NSLocalizedString(@"Oct", nil);
            break;
        case 11:
            string=NSLocalizedString(@"Nov", nil);
            break;
        case 12:
            string=NSLocalizedString(@"Dec", nil);
            break;
        default:
            break;
    }
    return string;
}

#pragma mark - 获取24小时功率
- (void)get24HEnergyInfo
{
    [xDayArray removeAllObjects];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [calendar components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    NSMutableArray *textArray = [[NSMutableArray alloc] init];
    for (int i=0; i<24; i++)
    {
        NSString *string;
        int hour = (int)([comps hour] + 24 - i);
        int hour_ = hour % 24 - 1;
        if (hour % 24 == 0) {
            hour_ = 23;
        }
        string = [NSString stringWithFormat:@"%d:00", hour % 24];
        [textArray insertObject:string atIndex:0];
    }
    [textArray insertObject:@"" atIndex:0];
    xDayArray = textArray;
    
    NSString *userStr = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERMODEL];
    NSString *passwordStr = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_PASSWORD];
    NSString *tempString = [Util getPassWordWithmd5:passwordStr];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:AccessKey forKey:@"accessKey"];
    [dict setValue:userStr forKey:@"username"];
    [dict setValue:tempString forKey:@"password"];
    [dict setValue:self.macStr forKey:@"macAddress"];
    [dict setValue:timeZone forKey:@"timeZone"];
    
    [HTTPService GetHttpToServerWith:dayEnergyInfoURL WithParameters:dict  success:^(NSDictionary *dic) {
        [dataDayArray removeAllObjects];

        NSString * success = [dic objectForKey:@"success"];
        
        if ([success boolValue] == true) {
            
            [dataDayArray removeAllObjects];

            NSArray *arr = [dic objectForKey:@"data"];
            if (arr == nil || arr.count == 0) {
                for (int i = 0; i < 24; i++) {
                    [dataDayArray addObject:@"0"];
                }
                return;
            }
            NSMutableArray *array = [NSMutableArray arrayWithArray:arr];
            NSDictionary *dic_ = arr[0];
            if ([[[dic_ allKeys] objectAtIndex:0] intValue] == (int)[comps hour]) {
                id object = [array objectAtIndex:0];
                [array removeObject:[array objectAtIndex:0]];
                [array insertObject:object atIndex:array.count];
            }
            int a = 0;
            for (int i = 1; i < 25; i++) {
                NSArray *arr = [[xDayArray objectAtIndex:i] componentsSeparatedByString:@":"];
                NSString *str = arr[0];
                
                NSDictionary *tempDic = array[a];
                
                if ([str isEqualToString:[[tempDic allKeys] objectAtIndex:0]]) {
                    
                    [dataDayArray addObject:[NSString stringWithFormat:@"%.2f", [[tempDic objectForKey:str] floatValue] * 1000]];
                    
                    a = a + 1;
                    if (a >= array.count) {
                        a = (int)array.count - 1;
                    }
                } else {
                    // 把没有上报数据的小时的数据 设置为0
                    [dataDayArray addObject:@"0"];
                }
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showEnergyDayView];
            });
        }
        if ([success boolValue] == false) {
            for (int i = 0; i < 24; i++) {
                [dataDayArray addObject:@"0"];
            }
//            [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:[dic objectForKey:@"msg"]];
            
        }
        
    } error:^(NSError *error) {
        for (int i = 0; i < 24; i++) {
            [dataDayArray addObject:@"0"];
        }
//        [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:NSLocalizedString(@"Link Timeout", nil)];
    }];
}

#pragma mark - 获取30天功率
- (void)getMonthEnergyInfo
{
    [xMonthArray removeAllObjects];
    
    NSMutableArray *dayArray = [[NSMutableArray alloc] init];
    NSMutableArray *dayArr = [[NSMutableArray alloc] init];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSMutableArray *tempArray_ = [[NSMutableArray alloc] init];
    
    if (today == dayNumberOfThisMonth) {
        for (int i = 1; i <= dayNumberOfThisMonth; i++) {
            [dayArr addObject:[NSString stringWithFormat:@"%dth",i]];
            [tempArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        if (dayNumberOfThisMonth == 31) {
            for (int i = 1; i < 31; i ++) {
                [dayArray addObject:dayArr[i]];
                [tempArray_ addObject:tempArray[i]];
            }
        }
        if (dayNumberOfThisMonth == 30) {
            for (int i = 0; i < 30; i ++) {
                [dayArray addObject:dayArr[i]];
                [tempArray_ addObject:tempArray[i]];
            }
        }
        if (dayNumberOfThisMonth < 30) {
            for (int i = 0; i < dayNumberOfThisMonth; i ++) {
                [dayArray addObject:dayArr[i]];
                [tempArray_ addObject:tempArray[i]];
            }
            if (dayNumberOfThisMonth == 29) {
                [dayArray insertObject:@"31th" atIndex:0];
                [tempArray_ insertObject:@"31th" atIndex:0];
            }
            if (dayNumberOfThisMonth == 28) {
                [dayArray insertObject:@"31th" atIndex:0];
                [tempArray_ insertObject:@"31th" atIndex:0];
                [dayArray insertObject:@"30th" atIndex:0];
                [tempArray_ insertObject:@"31th" atIndex:0];
            }
        }
    }
    if (today != dayNumberOfThisMonth) {
        if (today == 30) {
            for (int i = 1; i <= 30; i++) {
                [dayArray addObject:[NSString stringWithFormat:@"%dth",i]];
                [tempArray_ addObject:[NSString stringWithFormat:@"%d",i]];
            }
        } else {
            
            for (int i = 1; i <= dayNumberOfPreMonth; i++) {
                [dayArr addObject:[NSString stringWithFormat:@"%dth",i]];
                [tempArray addObject:[NSString stringWithFormat:@"%d",i]];
            }
            for (int i = today; i < dayNumberOfPreMonth; i++) {
                [dayArray addObject:[dayArr objectAtIndex:i]];
                [tempArray_ addObject:[tempArray objectAtIndex:i]];
            }
            for (int i = 0; i < today; i++) {
                [dayArray addObject:dayArr[i]];
                [tempArray_ addObject:tempArray[i]];
            }
            if (dayNumberOfPreMonth == 31) {
                [dayArray removeObjectAtIndex:0];
                [tempArray_ removeObjectAtIndex:0];
            }
 
            if (today == 1) {
                if (dayNumberOfPreMonth == 29) {
                    [dayArray insertObject:@"1th" atIndex:0];
                    [tempArray_ insertObject:@"1" atIndex:0];
                }
                if (dayNumberOfPreMonth == 28) {
                    [dayArray insertObject:@"1th" atIndex:0];
                    [dayArray insertObject:@"31th" atIndex:0];
                    [tempArray_ insertObject:@"1" atIndex:0];
                    [tempArray_ insertObject:@"31" atIndex:0];
                }
            }
            if (today == 2) {
                if (dayNumberOfPreMonth == 29) {
                    [dayArray insertObject:@"2th" atIndex:0];
                    [tempArray_ insertObject:@"2th" atIndex:0];
                }
                if (dayNumberOfPreMonth == 28) {
                    [dayArray insertObject:@"2th" atIndex:0];
                    [dayArray insertObject:@"1th" atIndex:0];
                    [tempArray_ insertObject:@"2" atIndex:0];
                    [tempArray_ insertObject:@"1" atIndex:0];
                }
            }
            if (today > 2) {
                
                if (dayNumberOfPreMonth == 29) {
                    [dayArray insertObject:[dayArr objectAtIndex:today - 1] atIndex:0];
                    [tempArray_ insertObject:[tempArray objectAtIndex:today - 1] atIndex:0];
                }
                if (dayNumberOfPreMonth == 28) {
                    [dayArray insertObject:[dayArr objectAtIndex:today - 1] atIndex:0];
                    [dayArray insertObject:[dayArr objectAtIndex:today - 2] atIndex:0];
                    [tempArray_ insertObject:[tempArray objectAtIndex:today - 1] atIndex:0];
                    [tempArray_ insertObject:[tempArray objectAtIndex:today - 2] atIndex:0];
                }
            }
        }
    }
    [dayArray insertObject:@"" atIndex:0];
    
    xMonthArray = dayArray;
    
    NSString *userStr = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERMODEL];
    NSString *passwordStr = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_PASSWORD];
    NSString *tempString = [Util getPassWordWithmd5:passwordStr];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:AccessKey forKey:@"accessKey"];
    [dict setValue:userStr forKey:@"username"];
    [dict setValue:tempString forKey:@"password"];
    [dict setValue:self.macStr forKey:@"macAddress"];
    [dict setValue:timeZone forKey:@"timeZone"];
    [dict setValue:@"30" forKey:@"days"];
    
    [HTTPService GetHttpToServerWith:monthEnergyInfoURL WithParameters:dict  success:^(NSDictionary *dic) {
        
        [dataMonthArray removeAllObjects];

        NSString * success = [dic objectForKey:@"success"];
        
        if ([success boolValue] == true) {
            
            NSArray *array =[dic objectForKey:@"data"];
            
            if (array == nil || array.count == 0) {
                for (int i = 0; i < 30; i++) {
                    [dataMonthArray addObject:@"0"];
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self showEnergyMonthView];
                });

                return;
            }
            int a = 0;
            for (int i = 1; i < 31; i++) {
                NSString *str = tempArray_[i - 1];
                
                NSDictionary *tempDic = array[a];
                if ([str isEqualToString:[[tempDic allKeys] objectAtIndex:0]]) {
                    [dataMonthArray addObject:[tempDic objectForKey:str]];
                    a = a + 1;
                    if (a >= array.count) {
                        a = (int)array.count - 1;
                    }
                    
                } else {
                    // 把没有上报数据的天数的数据 设置为0
                    [dataMonthArray addObject:@"0"];
                }
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showEnergyMonthView];
            });

        }
        if ([success boolValue] == false) {
            
            for (int i = 0; i < 30; i++) {
                [dataMonthArray addObject:@"0"];
            }
        }
        
    } error:^(NSError *error) {
        for (int i = 0; i < 30; i++) {
            [dataMonthArray addObject:@"0"];
        }
//        [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:NSLocalizedString(@"Link Timeout", nil)];
    }];
}

#pragma mark - 获取12个月功率
- (void)getYearEnergyInfo
{
    [dataYearArray removeAllObjects];
    
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    comps = [calendar components:unitFlags fromDate:date];
    
    //横坐标
    NSMutableArray *dayArray = [[NSMutableArray alloc] init];
    //保存每个月有多少天
    NSMutableArray *dayInMonth = [[NSMutableArray alloc] init];
    //  定义一个NSDateComponents对象，设置一个时间点
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponentsForDate = [[NSDateComponents alloc] init];
    NSDate *dateFromDateComponentsForDate;
    for (int i=0; i<12; i++)
    {
        NSString *string=@"";
        int countDayInMonth=0;
        int weekDay = (int)([comps month]+i+1);
        if(weekDay>12)
        {
            weekDay=weekDay-12;
            [dateComponentsForDate setYear:[comps year]];
        }
        else
        {
            [dateComponentsForDate setYear:[comps year]-1];
        }
        [dateComponentsForDate setMonth:weekDay];
        dateFromDateComponentsForDate= [greCalendar dateFromComponents:dateComponentsForDate];
        //计算每个月有多少天
        countDayInMonth=(int)[self getNumberOfMonth:dateFromDateComponentsForDate];
        string=[self turnToEnglishMonth:weekDay];
        [dayArray addObject:string];
        [tempArr addObject:[NSString stringWithFormat:@"%d", weekDay]];
        [dayInMonth addObject:[NSNumber numberWithInt:countDayInMonth]];
    }
    [dayArray insertObject:@"" atIndex:0];
    xYearArray = dayArray;
    
    NSString *userStr = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERMODEL];
    NSString *passwordStr = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_PASSWORD];
    NSString *tempString = [Util getPassWordWithmd5:passwordStr];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:AccessKey forKey:@"accessKey"];
    [dict setValue:userStr forKey:@"username"];
    [dict setValue:tempString forKey:@"password"];
    [dict setValue:self.macStr forKey:@"macAddress"];
    
    [HTTPService GetHttpToServerWith:yearEnergyInfoURL WithParameters:dict  success:^(NSDictionary *dic) {
        [dataYearArray removeAllObjects];

        NSString * success = [dic objectForKey:@"success"];
        
        if ([success boolValue] == true) {
            
            NSArray *array =[dic objectForKey:@"data"];
            
            if (array == nil || array.count == 0) {
                for (int i = 0; i < 12; i++) {
                    [dataYearArray addObject:@"0"];
                }
                return;
            }
            
            int a = 0;
            for (int i = 0; i < 12; i++) {
                NSString *str = tempArr[i];
                
                NSDictionary *tempDic = array[a];
                if ([str isEqualToString:[[tempDic allKeys] objectAtIndex:0]]) {
                    [dataYearArray addObject:[tempDic objectForKey:str]];
                    a = a + 1;
                    if (a >= array.count) {
                        a = (int)array.count - 1;
                    }
                } else {
                    // 把没有上报数据的天数的数据 设置为0
                    [dataYearArray addObject:@"0"];
                }
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showEnergyYearView];
            });

        }
        if ([success boolValue] == false) {
            for (int i = 0; i < 12; i++) {
                [dataYearArray addObject:@"0"];
            }
//            [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:[dic objectForKey:@"msg"]];
        }

    } error:^(NSError *error) {
        for (int i = 0; i < 12; i++) {
            [dataYearArray addObject:@"0"];
        }
//        [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:NSLocalizedString(@"Link Timeout", nil)];
    }];
}

#pragma mark - navBarButton method
- (void)leftButtonMethod:(UIButton *)but
{
    [real_timeEnergyTimer invalidate];
    real_timeEnergyTimer = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadButtonMethod:(UIButton *)sender
{
    ElectricityPriceVC *priceVC = [[ElectricityPriceVC alloc] init];
    priceVC.macStr = self.macStr;
    [self.navigationController pushViewController:priceVC animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float height = (kScreen_Height == 480) ? 40 : 55;

    if (scrollView == kindScrollView) {
        CGFloat current_x = scrollView.contentOffset.x;
        NSInteger current = current_x / [UIScreen mainScreen].bounds.size.width;
        
        for (int i = 0; i < 4; i++) {
            UIButton *btn = (UIButton *)[self.view viewWithTag:1000 + i];
            if (i == current) {
                [indicator setFrame:CGRectMake(btn.frame.origin.x, barViewHeight + height - 3, btn.frame.size.width, 3)];
                [btn setTitleColor:RGBA(0, 170, 230, 1) forState:UIControlStateNormal];
            } else {
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
        }
    } else {
        kindScrollView.scrollEnabled = NO;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
