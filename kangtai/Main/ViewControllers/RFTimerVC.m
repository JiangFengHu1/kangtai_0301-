//
//
/**
 * Copyright (c) www.bugull.com
 */
//
//
#import "RFTimerVC.h"
#import "ZQCustomTimePicker.h"

@interface RFTimerVC ()
{
    ZQCustomTimePicker *timePicker;
    NSString *nowYearStr;
    NSString *nowMonthStr;
    NSString *nowDayStr;
    NSMutableArray *taskIndexArr;
    NSMutableArray *chooseArr;
}

@property (nonatomic, assign)UInt8 hour;

@property (nonatomic, assign)UInt8 min;

@property (nonatomic, assign)UInt8 flag;

@property (nonatomic, assign)BOOL isOFF;


@property (nonatomic, strong)NSMutableArray *mutableArr;

@property (nonatomic, assign)UInt8 dateDD;


@end

@implementation RFTimerVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.indexArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        // Custom initialization
    }
    return self;
}

static int numberoftasks = 1;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mutableArr = [[NSMutableArray alloc] initWithCapacity:7];
    chooseArr = [NSMutableArray arrayWithObjects:@"0", @"0", @"0", @"0", @"0", @"0", @"0", nil];
    taskIndexArr = [NSMutableArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", nil];
    self.isOFF = [self.typeStr isEqualToString:@"add"] ? YES : (([self.indexArray[2] intValue] == 1) ? YES : NO);
    if (self.indexArray.count > 0 && [self.typeStr isEqualToString:@"add"]) {
        
        for (NSDictionary *dict in self.indexArray) {
            
            if ([taskIndexArr containsObject:dict[@"indx"]]) {
                [taskIndexArr removeObject:dict[@"indx"]];
            }
        }
    }
    
    [self loadUI];
}

- (void)loadUI
{
    self.titlelab.text = [self.typeStr isEqualToString:@"add"] ? NSLocalizedString(@"Add Timer",nil) : NSLocalizedString(@"Edit Timer", nil);
    self.titlelab.bounds = CGRectMake(0, 0, 200, 40);
    self.view.backgroundColor = RGBA(248.0, 248.0, 248.0, 1.0);
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, self.barView.frame.size.height, 90, kScreen_Height - self.barView.frame.size.height)];
    leftView.backgroundColor = RGBA(242.0, 242.0, 242.0, 1.0);
    [self.view addSubview:leftView];
    UIView *firstLineView = [[UIView alloc] initWithFrame:CGRectMake(leftView.frame.size.width, (int)(kScreen_Height - self.barView.frame.size.height) / 2 + 34, kScreen_Width - leftView.frame.size.width, 1)];
    firstLineView.backgroundColor = RGBA(220.0, 220.0, 220.0, 1.0);
    [self.view addSubview:firstLineView];
    UIView *secondLineView = [[UIView alloc] initWithFrame:CGRectMake(leftView.frame.size.width, (int)(kScreen_Height - self.barView.frame.size.height) / 2 + 114, kScreen_Width - leftView.frame.size.width, 1)];
    secondLineView.backgroundColor = RGBA(220.0, 220.0, 220.0, 1.0);
    [self.view addSubview:secondLineView];
    
    UILabel *afterLab = [[UILabel alloc] initWithFrame:CGRectMake(13, self.barView.frame.size.height - 44 + firstLineView.frame.origin.y / 2, 80, 40)];
    afterLab.backgroundColor = [UIColor clearColor];
    afterLab.font = [UIFont systemFontOfSize:18];
    afterLab.text = NSLocalizedString(@"Time",nil);
    afterLab.adjustsFontSizeToFitWidth = YES;
    afterLab.numberOfLines = 0;
    afterLab.textColor = RGBA(0.0, 0.0, 0.0, 1.0);
    [self.view addSubview:afterLab];
    
    UILabel *actionLab = [[UILabel alloc] initWithFrame:CGRectMake(13, (firstLineView.frame.origin.y + secondLineView.frame.origin.y) / 2 - 21, 80, 40)];
    actionLab.backgroundColor = [UIColor clearColor];
    actionLab.font = [UIFont systemFontOfSize:18];
    actionLab.text = NSLocalizedString(@"Action", nil);
    actionLab.adjustsFontSizeToFitWidth = YES;
    actionLab.numberOfLines = 0;
    actionLab.textColor = RGBA(0.0, 0.0, 0.0, 1.0);
    [self.view addSubview:actionLab];
    
    NSArray *actionNameArr = [self.rfType isEqualToString:@"3"] ? @[NSLocalizedString(@"Up", nil), NSLocalizedString(@"Down", nil)] : ([self.rfType isEqualToString:@"4"] ? @[NSLocalizedString(@"High", nil), NSLocalizedString(@"Low", nil)] : @[NSLocalizedString(@"ON", nil), NSLocalizedString(@"OFF", nil)]);
    NSArray *imgArr = self.isOFF ? @[@"valid__2", @"invalid_2"] : @[@"invalid_2", @"valid__2"];
    for (int i = 0; i < 2; i++) {
        UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        actionBtn.frame = CGRectMake(leftView.frame.size.width, actionLab.center.y - 37 + i * 42, kScreen_Width - leftView.frame.size.width, 35);
        actionBtn.tag = 100 + i;
        [actionBtn addTarget:self action:@selector(switchButtDeviceMethod:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:actionBtn];

        UIImageView *actionImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 25, 25)];
        actionImgView.image = [UIImage imageNamed:imgArr[i]];
        actionImgView.tag = 200 + i;
        [actionBtn addSubview:actionImgView];
        
        UILabel *actionNameLab = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, kScreen_Width - leftView.frame.size.width - 55, 35)];
        actionNameLab.backgroundColor = [UIColor clearColor];
        actionLab.adjustsFontSizeToFitWidth = YES;
        actionNameLab.font = [UIFont systemFontOfSize:18];
        actionNameLab.text = actionNameArr[i];
        actionNameLab.textColor = RGBA(164.0, 164.0, 164.0, 1.0);
        [actionBtn addSubview:actionNameLab];
    }
    
    UIButton *switchButt = [UIButton buttonWithType:UIButtonTypeCustom];
    switchButt.frame = CGRectMake(leftView.frame.size.width + 25, actionLab.center.y - 30, 65, 65);
    
    float pickerF = (kScreen_Height == 480) ? 5 : 28;
    float x = (float)kScreen_Width / 320;
    float y = (float)kScreen_Height / 568;
    float h = (kScreen_Width > 320) ? y : 1;
    
    timePicker = [[ZQCustomTimePicker alloc] initWithFrame:CGRectMake((leftView.frame.size.width + 20) * x, (barViewHeight + pickerF) * h, 205, 170) withIsZero:NO andSetTimeString:[self.typeStr isEqualToString:@"add"] ? nil : self.indexArray[0]];
    [self.view addSubview:timePicker];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:now];
    NSInteger monthInt = [dateString substringWithRange:NSMakeRange(4, 2)].integerValue;
    NSInteger dayInt = [dateString substringWithRange:NSMakeRange(6, 2)].integerValue;
    NSString *nowDateString = [NSString stringWithFormat:@"%@-%ld-%ld %@:%@:%@",[dateString substringWithRange:NSMakeRange(0, 4)],(long)monthInt,(long)dayInt,[dateString substringWithRange:NSMakeRange(8, 2)],[dateString substringWithRange:NSMakeRange(10, 2)],[dateString substringWithRange:NSMakeRange(12, 2)]];
    nowYearStr = [dateString substringWithRange:NSMakeRange(0, 4)];
    nowMonthStr = [dateString substringWithRange:NSMakeRange(4, 2)];
    nowDayStr = [dateString substringWithRange:NSMakeRange(6, 2)];
    NSString *utcStr = [self getUTCFormateLocalDate:nowDateString];
    NSArray *array =  [utcStr componentsSeparatedByString:@"T"];
    NSString *timeString =  [array objectAtIndex:1];
    NSArray *timeArray =  [timeString componentsSeparatedByString:@":"];
    self.hour = [[timeArray objectAtIndex:0] intValue];
    self.min = [[timeArray objectAtIndex:1] intValue];
    
    NSArray *repeatArr;
    if ([self.typeStr isEqualToString:@"edit"]) {
        
        repeatArr = [self.indexArray[1] componentsSeparatedByString:@"、"];
    }
    
    CGSize size = [Util sizeForText:NSLocalizedString(@"Repeat", nil) Font:18.f forWidth:58];

    UILabel *repeatLabel = [[UILabel alloc] initWithFrame:CGRectMake(actionLab.frame.origin.x, actionLab.frame.origin.y +actionLab.frame.origin.y - afterLab.frame.origin.y - 22, 58, size.height)];
    repeatLabel.numberOfLines = 0;
    repeatLabel.lineBreakMode = NSLineBreakByCharWrapping;
    repeatLabel.backgroundColor = [UIColor clearColor];
    repeatLabel.font = [UIFont systemFontOfSize:18];
    repeatLabel.text = NSLocalizedString(@"Repeat", nil);
    repeatLabel.textColor = RGBA(0.0, 0.0, 0.0, 1.0);
    [self.view addSubview:repeatLabel];
    NSArray *arr = [NSArray arrayWithObjects:NSLocalizedString(@"Sun", nil),NSLocalizedString(@"Mon", nil),NSLocalizedString(@"Tue", nil),NSLocalizedString(@"Wed", nil),NSLocalizedString(@"Thu", nil),NSLocalizedString(@"Fri", nil),NSLocalizedString(@"Sat", nil),nil];
    
    float repeatF = (kScreen_Height == 480) ? 100 : 120;
    for (int i=0; i < 7; i ++) {
        
        UIButton *dataButt = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i < 4) {
            dataButt.frame = CGRectMake(i * 50 + (switchButt.frame.origin.x - 15) * x, switchButt.frame.origin.y + repeatF * h, 50, 48);
        } else {
            dataButt.frame = CGRectMake((i-4) * 50 + (switchButt.frame.origin.x - 15) * x, switchButt.frame.origin.y + (repeatF + 50) * h, 50, 48);
        }
        [dataButt addTarget:self action:@selector(dataButtDeviceMethod:) forControlEvents:UIControlEventTouchUpInside];
        dataButt.tag = i +666;
        [dataButt setTitle:[arr objectAtIndex:i] forState:UIControlStateNormal];
        dataButt.titleLabel.font = [UIFont systemFontOfSize:21];
        [dataButt setTitleColor:[UIColor colorWithRed:164.0/255 green:164.0/255 blue:164.0/255 alpha:1] forState:UIControlStateNormal];
        [self.view addSubview:dataButt];
        
        if ([self.typeStr isEqualToString:@"edit"]) {
            for (int j = 0; j < repeatArr.count; j++) {
                if ([arr[i] isEqualToString:repeatArr[j]]) {
                    [dataButt setTitleColor:[UIColor colorWithRed:20/255 green:170.0/255 blue:240.0/255 alpha:1] forState:UIControlStateNormal];
                    
                    [chooseArr replaceObjectAtIndex:i withObject:@"1"];
                    [self.mutableArr addObject:[NSString stringWithFormat:@"%d", i]];
                }
            }
        }
    }
}

- (NSString *)getUTCFormateLocalDate:(NSString *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:localDate];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}

#pragma mark-
#pragma mark-Event
- (void)reloadButtonMethod:(UIButton *)sender
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit |NSCalendarUnitMinute |NSCalendarUnitSecond | NSCalendarUnitHour fromDate:[NSDate date]];
    
    NSString *strimg = [NSString stringWithFormat:@"%ld-%ld-%ld %02ld:%02ld:%02ld",(long)[components year],(long)[components month],(long)[components day],(long)timePicker.hourPicker.currentItemIndex,(long)timePicker.minutePicker.currentItemIndex,(long)[components second]];
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init] ;
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* inputDate = [inputFormatter dateFromString:strimg];
    
    [self yymmdd:[NSString stringWithFormat:@"%@year%@month%@day", nowYearStr,nowMonthStr,nowDayStr] hour: timePicker.hourPicker.currentItemIndex min:timePicker.minutePicker.currentItemIndex Withdate:inputDate];
    
    [self RestructuringData];
    
    BitSwitch bitFlag = kBit8On;
    self.flag = self.flag | bitFlag;
    
    if ([self.typeStr isEqualToString:@"edit"]) {
        numberoftasks = self.taskNumber;
    } else {
        numberoftasks = [taskIndexArr[0] intValue];
    }
    
    Device *device = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:self.macString];
    NSLog(@"=== %d %d",self.hour, self.min);
    
    //  设置定时
    if (self.rfAddress == nil) {
        [DeviceManagerInstance setTimeringAlermWithMacString:device.mac Withhost:device.host flag:self.flag Hour:self.hour min:self.min TaskCount:numberoftasks Switch:self.isOFF key:device.key With:device.localContent deviceType:device.deviceType];
    } else {
        
        NSMutableDictionary *timerDic = [NSMutableDictionary dictionary];
        [timerDic setObject:[NSString stringWithFormat:@"%d", numberoftasks] forKey:@"Num"];
        [timerDic setObject:[NSString stringWithFormat:@"%d", self.flag] forKey:@"Flag"];
        [timerDic setObject:[NSString stringWithFormat:@"%d", self.hour] forKey:@"Hour"];
        [timerDic setObject:[NSString stringWithFormat:@"%d", self.min] forKey:@"Min"];
        
        Device *device = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:self.macString];
        [DeviceManagerInstance set433TodeviceWithMacString:device.mac WithHost:device.host Open:self.isOFF withArc4Address:self.rfAddress deviceType:self.rfType With:device.localContent timerDic:timerDic];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)switchButtDeviceMethod:(UIButton *)but
{
    for (int i = 0; i < 2; i++) {
        UIImageView *tempImgView = (UIImageView *)[self.view viewWithTag:200 + i];
        if (i == but.tag - 100) {
            tempImgView.image = [UIImage imageNamed:@"valid__2"];
        } else {
            tempImgView.image = [UIImage imageNamed:@"invalid_2"];
        }
    }
    self.isOFF = (but.tag - 100 == 0);
}

- (void)dataButtDeviceMethod:(UIButton *)but
{
    NSInteger indx = but.tag - 666;
    //    反选；
    bool isSelected = !but.isSelected;
    [but setSelected:isSelected];
    
    NSString *string = nil;
    string = [NSString stringWithFormat:@"%ld",(long)indx];
    if ([self.typeStr isEqualToString:@"add"]) {
        if (isSelected) {
            [but setTitleColor:[UIColor colorWithRed:20/255 green:170.0/255 blue:240.0/255 alpha:1] forState:UIControlStateNormal];
            
            [self.mutableArr addObject:string];
            
        }else{
            [but setTitleColor:[UIColor colorWithRed:164.0/255 green:164.0/255 blue:164.0/255 alpha:1] forState:UIControlStateNormal];
            
            [self.mutableArr removeObject:string];
        }
        
    } else {
        
        if ([chooseArr[indx] isEqualToString:@"1"]) {
            [but setTitleColor:[UIColor colorWithRed:164.0/255 green:164.0/255 blue:164.0/255 alpha:1] forState:UIControlStateNormal];
            
            [self.mutableArr removeObject:string];
            [chooseArr replaceObjectAtIndex:indx withObject:@"0"];
        } else {
            
            [but setTitleColor:[UIColor colorWithRed:20/255 green:170.0/255 blue:240.0/255 alpha:1] forState:UIControlStateNormal];
            
            [self.mutableArr addObject:string];
            [chooseArr replaceObjectAtIndex:indx withObject:@"1"];
        }
    }
}

#pragma mark-
#pragma mark-UIDatePicker

- (void)yymmdd:(NSString *)string hour:(NSInteger)hour min:(NSInteger)min Withdate:(NSDate *)nowDate
{
    NSArray *array = [self loadDataWithDate:nowDate WithDateOrTime:NO];
    
    NSString*hou = [array objectAtIndex:0];
    NSString*mi = [array objectAtIndex:1];
    self.hour = [hou intValue];
    self.min = [mi intValue];
}

#pragma mark-
#pragma mark-组装Flag
- (void)RestructuringData
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit |NSCalendarUnitMinute |NSCalendarUnitSecond | NSCalendarUnitHour fromDate:[NSDate date]];
    NSInteger currentWeekDay = [components weekday];
    
    for (NSString *str in self.mutableArr) {
        
        int index =   [str intValue];
        if ((currentWeekDay-self.dateDD) == 1 || (currentWeekDay-self.dateDD) == -6)
        {
            
            if (index == 0) {
                index = 7;
            }
            
            index = index-1;
            
        }
        
        if ((currentWeekDay-self.dateDD) == -1 || (currentWeekDay-self.dateDD) == 6) {
            if (index == 7 ) {
                index = 0;
            }
            
            index = index + 1;
            
        }
        BitSwitch bitFlag;
        switch (index) {
            case 0://周一
                
                bitFlag = kBit7On;
                
                break;
            case 1://周二
                
                
                bitFlag = kBit1On;
                
                break;
            case 2://周三
                
                bitFlag = kBit2On;
                
                break;
            case 3://周四
                bitFlag = kBit3On;
                
                break;
            case 4://周五
                bitFlag = kBit4On;
                
                break;
            case 5://周六
                bitFlag = kBit5On;
                
                break;
            case 6://周日
                bitFlag = kBit6On;
                
                break;
                
            default:
                break;
        }
        self.flag = self.flag | bitFlag;
    }
}


- (NSDate *)dateStingAndMinWith:(UInt8 )hour WIthMin:(UInt8)min With:(NSString *)moth
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSDate *utcData = [NSDate date];
    
    NSString *utcDatatemp =  [NSString stringWithFormat:@"%@",utcData];
    NSArray *utcDataarray = [utcDatatemp componentsSeparatedByString:@" "];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ssZ";
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [df setTimeZone:gmt];
    
    NSDate *datessss;
    if (moth == nil) {
        datessss =[df dateFromString:[NSString stringWithFormat:@"%@ %d:%d:30+0000",[utcDataarray objectAtIndex:0],hour,min]];
        
    }else{
        datessss =[df dateFromString:[NSString stringWithFormat:@"%@ %d:%d:30+0000",moth,hour,min]];
        
    }
    return  datessss;
}

#pragma mark-
#pragma mark-转换GMT+0时间

- (NSArray *)loadDataWithDate:(NSDate *)date WithDateOrTime:(BOOL)isDate
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit |NSCalendarUnitMinute |NSCalendarUnitSecond | NSCalendarUnitHour fromDate:date];
    
    NSDateFormatter* dateFo = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
    
    [dateFo setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//设定时间格式,这里可以设置成自己需要的格式
    
    
    NSDate *datessss =[dateFo dateFromString:[NSString stringWithFormat:@"%ld-%ld-%ld %ld:%ld:%ld",(long)[components year],(long)[components month],(long)[components day],(long)[components hour],(long)[components minute],(long)[components second]]];
    dateFo.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];//这就是GMT+0时区了
    NSString *dateString = [dateFo stringFromDate:datessss];
    
    
    NSArray *array =  [dateString componentsSeparatedByString:@" "];
    
    NSString *daString =  [array objectAtIndex:0];
    
    NSString *timeString =  [array objectAtIndex:1];
    
    NSArray *dateArray =  [daString componentsSeparatedByString:@"-"];
    //    self.dateDD = [[dateArray objectAtIndex:2] intValue];
    self.dateDD = [components weekday];
    NSArray *timeArray =  [timeString componentsSeparatedByString:@":"];
    if (isDate == YES) {
        return dateArray;
    }
    else{
        return timeArray;
    }
    return nil;
}

- (void)leftButtonMethod:(UIButton *)but
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end