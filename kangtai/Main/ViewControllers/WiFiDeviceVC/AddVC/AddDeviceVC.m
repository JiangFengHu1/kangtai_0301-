//
//
/**
 * Copyright (c) www.bugull.com
 */
//
//

#import "AddDeviceVC.h"
#import <arpa/inet.h>
#import <ifaddrs.h>
#import "DeviceManager.h"
#import "Gogle.h"

@interface AddDeviceVC ()
{
    UIView *_indicView;
    UILabel * waitingLabel;
    UIImageView *imgView;
    NSTimer *_timer;
    NSTimer * searchTimer;
    HFSmartLink *smtlk;
    int smtlkState;
    
    NSInteger times;
    NSInteger findTimes;
    
    UIButton *butt;
    
    HiJoine *joine;
}

@property (nonatomic,assign)int  dext;

@property (strong,nonatomic) NSMutableSet * macSet;
@property (strong,nonatomic) NSMutableArray *macArray;
@property (strong,nonatomic) NSTimer * connectTimer;

@end

@implementation AddDeviceVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        smtlk = [HFSmartLink shareInstence];
        smtlk.isConfigOneDevice = NO;
        smtlk.waitTimers = 10;
        
        joine = [[HiJoine alloc] init];
        joine.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _macSet = [NSMutableSet set];
    
    [self layUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
}

- (void)startSmartLink
{
    [smtlk startWithKey:self.pwdStr processblock:^(NSInteger process) {
        NSLog(@"=== %d ==", (int)process);
    } successBlock:^(HFSmartLinkDeviceInfo *dev) {
        NSLog(@"config info=== %@ %@ ==", dev.mac, dev.ip);
    } failBlock:^(NSString *failmsg) {
        NSLog(@"error === %@ ", failmsg);
    } endBlock:^(NSDictionary *deviceDic) {
        NSLog(@"deviceDic === %@ ", deviceDic);
    }];
    
    // 利尔达模块
    [joine setBoardDataWithPassword:self.pwdStr withBackBlock:^(NSInteger result, NSString *message) {
        NSLog(@"利尔达: result = %d message = %@",(int)result, message);
    }];
}


- (void)stopSmartLink
{
    [smtlk stopWithBlock:^(NSString *stopMsg, BOOL isOk) {
        if(isOk){
            NSLog(@"stopMsg === %@ ", stopMsg);
        }else{
            NSLog(@"stopMsg === %@ ", stopMsg);
        }
    }];
}

- (void)startMethod:(UIButton *)but
{
    [self startAnimation];
    [self.view endEditing:YES];
    
    NSString *broadcastAddress = [Util getBroadcastAddress];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:broadcastAddress forKey:@"broadcastAddress"];
    [userDefaults synchronize];
    
    searchTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(sendaddDeviceTo:) userInfo:nil repeats:YES];
    [searchTimer fire];
    
    _indicView.hidden = NO;
    self.imageVW.hidden = YES;
    self.titlelab.hidden = YES;
    self.rightBut.hidden = YES;
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"return_gray.png"] forState:UIControlStateNormal];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"return_gray_click.png"] forState:UIControlStateHighlighted];
    
    if (smtlk == nil)
    {
        smtlk = [HFSmartLink shareInstence];
        smtlk.isConfigOneDevice = NO;
    }
    [self startSmartLink];
}

#pragma mark - sendaddDeviceTo
- (void)sendaddDeviceTo:(NSTimer *)tim
{
    self.dext ++;
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [LocalServiceInstance addDeviceToFMDBWithisAdd:NO WithMac:nil];
        [LocalServiceInstance addEnergyDeviceToFMDBWithisAdd:NO WithMac:nil];
        [LocalServiceInstance addRFDeviceToFMDBWithisAdd:NO WithMac:nil];
//    });

    if (self.dext > 10) {
        [tim invalidate];
        tim = nil;
        _indicView.hidden = YES;
        self.imageVW.hidden = NO;
        self.titlelab.hidden = NO;
        [Util getAppDelegate].rootVC.pan.enabled = YES;
        [self stopAnimation];
        [self stopSmartLink];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)layUI
{
    self.titlelab.text = NSLocalizedString(@"Add Device",nil);
    self.rightBut.hidden = YES;
    
    CGSize size = [Util sizeForText:NSLocalizedString(@"Search device and connect it to WiFi",nil) Font:16.f forWidth:kScreen_Width - 40];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(20, barViewHeight + 16, kScreen_Width - 40, size.height)];
    lab.backgroundColor = [UIColor clearColor];
    lab.font = [UIFont systemFontOfSize:16];
    lab.text = NSLocalizedString(@"Search device and connect it to WiFi",nil);
    lab.numberOfLines = 0;
    lab.textColor = [UIColor colorWithRed:151.0/255 green:151.0/255 blue:151.0/255 alpha:1];
    [self.view addSubview:lab];
    
    UIImageView *wifiImgView = [[UIImageView alloc] initWithFrame:CGRectMake(18, barViewHeight + 30 + size.height, kScreen_Width - 36, 100)];
    wifiImgView.image = [UIImage imageNamed:@"wifi_back_squre.png"];
    [self.view addSubview:wifiImgView];
    
    UILabel *ssidLab = [[UILabel alloc] initWithFrame:CGRectMake(20, barViewHeight + 35 + size.height, 80 * (float) (kScreen_Width / 320), 48)];
    ssidLab.backgroundColor = [UIColor clearColor];
    ssidLab.font = [UIFont systemFontOfSize:16];
    ssidLab.text = NSLocalizedString(@"WiFi SSID", nil);
    ssidLab.numberOfLines = 0;
    ssidLab.textAlignment = NSTextAlignmentCenter;
    ssidLab.textColor = [UIColor colorWithRed:39.0/255 green:39.0/255 blue:39.0/255 alpha:1];
    [self.view addSubview:ssidLab];
    
    UILabel *pwdLab = [[UILabel alloc] initWithFrame:CGRectMake(20, barViewHeight + 81 + size.height, 80 * (float) (kScreen_Width / 320), 48)];
    pwdLab.backgroundColor = [UIColor clearColor];
    pwdLab.textAlignment = NSTextAlignmentCenter;
    pwdLab.font = [UIFont systemFontOfSize:16];
    pwdLab.adjustsFontSizeToFitWidth = YES;
    pwdLab.text = NSLocalizedString(@"Password", nil);
    pwdLab.numberOfLines = 0;
    pwdLab.textColor = [UIColor colorWithRed:39.0/255 green:39.0/255 blue:39.0/255 alpha:1];
    [self.view addSubview:pwdLab];
    
    UILabel *showPwdLab = [[UILabel alloc] initWithFrame:CGRectMake(115 * (float) (kScreen_Width / 320) + 22, barViewHeight + 145 + size.height, 120, 25)];
    showPwdLab.backgroundColor = [UIColor clearColor];
    showPwdLab.adjustsFontSizeToFitWidth = YES;
    showPwdLab.font = [UIFont systemFontOfSize:16];
    showPwdLab.text = NSLocalizedString(@"Show Password", nil);
    showPwdLab.textColor = [UIColor colorWithRed:151.0/255 green:151.0/255 blue:151.0/255 alpha:1];
    [self.view addSubview:showPwdLab];
    UITapGestureRecognizer *showPWDTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPasswordMethod)];
    showPwdLab.userInteractionEnabled = YES;
    [showPwdLab addGestureRecognizer:showPWDTap];
    
    self.deviceName = [[UILabel alloc] initWithFrame:CGRectMake(115 * (float) (kScreen_Width / 320), barViewHeight + 33 + size.height, kScreen_Width - 136, 50)];
    self.deviceName.backgroundColor = [UIColor clearColor];
    self.deviceName.font = [UIFont systemFontOfSize:17];
    self.deviceName.text = [Util getCurrentWifiName];
    self.deviceName.numberOfLines = 0;
    self.deviceName.textColor = [UIColor colorWithRed:52.0/255 green:148.0/255 blue:225.0/255 alpha:1];
    [self.view addSubview:self.deviceName];
    
    butt = [UIButton buttonWithType:UIButtonTypeCustom];
    butt.frame = CGRectMake(105 * (float) (kScreen_Width / 320), barViewHeight + 146 + size.height, 25, 25);
    [butt addTarget:self action:@selector(showPasswordMethod) forControlEvents:UIControlEventTouchUpInside];
    [butt setImage:[UIImage imageNamed:@"invalid.png"] forState:UIControlStateNormal];
    [self.view addSubview:butt];
    
    self.pwdText = [[UITextField alloc] initWithFrame:CGRectMake(115 * (float) (kScreen_Width / 320), barViewHeight + 81 + size.height, kScreen_Width - 136, 50)];
    self.pwdText.borderStyle = UITextBorderStyleNone;
    self.pwdText.secureTextEntry = YES;
    self.pwdText.delegate = self;
    self.pwdText.textAlignment = NSTextAlignmentLeft;
    self.pwdText.textColor = [UIColor colorWithRed:52.0/255 green:148.0/255 blue:225.0/255 alpha:1];
    self.pwdText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:self.pwdText];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame = CGRectMake(20, kScreen_Height - 163, kScreen_Width - 40, 41);
    [startBtn setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startBtn setBackgroundImage:[UIImage imageNamed:@"updata_button_normal.png"] forState:UIControlStateNormal];
    [startBtn setBackgroundImage:[UIImage imageNamed:@"updata_button_click.png"] forState:UIControlStateHighlighted];
    [self.view addSubview:startBtn];
    [startBtn addTarget:self action:@selector(startMethod:) forControlEvents:UIControlEventTouchUpInside];
    
    _indicView = [[UIView alloc] init];
    _indicView.backgroundColor = [UIColor grayColor];
    _indicView.frame = CGRectMake(0, barViewHeight, kScreen_Width, kScreen_Height-barViewHeight);
    _indicView.backgroundColor =  [UIColor colorWithRed:241.0/255 green:241.0/255 blue:240.0/255 alpha:1];
    
    _indicView.hidden = YES;
    [self.view addSubview:_indicView];
    waitingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (kScreen_Height - barViewHeight) / 2 - 95, kScreen_Width, 40)];
    waitingLabel.backgroundColor = [UIColor clearColor];
    waitingLabel.textAlignment = NSTextAlignmentCenter;
    waitingLabel.font = [UIFont systemFontOfSize:15];
    waitingLabel.text = NSLocalizedString(@"Connection process may take 30 seconds, please wait ...", nil);
    waitingLabel.numberOfLines = 0;
    waitingLabel.textColor = [UIColor colorWithRed:151.0/255 green:151.0/255 blue:151.0/255 alpha:1] ;
    [_indicView addSubview:waitingLabel];
    
    imgView = [[UIImageView alloc] init];
    imgView.frame = CGRectMake(0, waitingLabel.frame.origin.y + 75, 45, 45);
    imgView.center = CGPointMake(kScreen_Width / 2, imgView.frame.origin.y);
    imgView.image = [UIImage imageNamed:@"waiting.png"];
    [_indicView addSubview:imgView];
}

- (void)startAnimation
{
    imgView.transform = CGAffineTransformIdentity;
    _timer = [NSTimer timerWithTimeInterval:.1 target:self selector:@selector(animate:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)stopAnimation
{
    [_timer invalidate];
    _timer = nil;
}

- (void)animate:(NSTimer *)timer
{
    imgView.transform = CGAffineTransformRotate(imgView.transform, DEGREES_TO_RADIANS(30));
}

- (void)leftButtonMethod:(UIButton *)but
{
    [searchTimer invalidate];
    searchTimer = nil;
    [self stopAnimation];
    [self stopSmartLink];
    [Util getAppDelegate].rootVC.pan.enabled = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showPasswordMethod
{
    if (self.isShowPW == NO)
    {
        [butt setImage:[UIImage imageNamed:@"valid.png"] forState:UIControlStateNormal];
        self.isShowPW = YES;
        self.pwdText.secureTextEntry = NO;
    } else {
        
        [butt setImage:[UIImage imageNamed:@"invalid.png"] forState:UIControlStateNormal];
        self.isShowPW = NO;
        self.pwdText.secureTextEntry = YES;
    }
}

#pragma mark - TextFieldDelegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.pwdStr = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
