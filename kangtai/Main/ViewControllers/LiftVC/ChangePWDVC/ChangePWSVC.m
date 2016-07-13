//
//
/**
 * Copyright (c) www.bugull.com
 */
//
//

#import "ChangePWSVC.h"
#import "LiftMenuVC.h"

@interface ChangePWSVC ()<UITextFieldDelegate,UIAlertViewDelegate>
{
    UIButton *butt;
}

@property(nonatomic,strong)NSString *oldString;
@property(nonatomic,strong)NSString *newpassString;
@property(nonatomic,strong)NSString *confirmpassString;

@property(nonatomic,strong)UITextField *oldPsText;

@property(nonatomic,strong)UITextField *newpassText;

@property(nonatomic,strong)UITextField *confirmpsText;


@end

@implementation ChangePWSVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layUI];
    // Do any additional setup after loading the view.
}
- (void)layUI
{
    //    change_password_backsqure.png
    self.titlelab.text = NSLocalizedString(@"Change Password", nil);
    self.titlelab.bounds = CGRectMake(0, 0, 200, 40);
    
    UIImageView *textImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"change_password_squre.png"]];
    textImage.frame = CGRectMake(20, barViewHeight + 28, kScreen_Width - 40, 165);
    [self.view addSubview:textImage];
    
    self.oldPsText = [[UITextField alloc] initWithFrame:CGRectMake(25, barViewHeight + 31, kScreen_Width - 45, 52)];
    self.oldPsText.font = [UIFont systemFontOfSize:16];
    self.oldPsText.placeholder = NSLocalizedString(@"Old password", nil);
    self.oldPsText.textAlignment = NSTextAlignmentLeft;
    self.oldPsText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.oldPsText.borderStyle = UITextBorderStyleNone;
    
    self.oldPsText.tag = 111;
    self.oldPsText.delegate = self;
    self.oldPsText.secureTextEntry = YES;
    [self.view addSubview:self.oldPsText];
    
    self.newpassText = [[UITextField alloc] initWithFrame:CGRectMake(25, barViewHeight + 86, kScreen_Width - 45, 52)];
    self.newpassText.placeholder = NSLocalizedString(@"New password", nil);
    self.newpassText.textAlignment = NSTextAlignmentLeft;
    self.newpassText.font = [UIFont systemFontOfSize:16];
    self.newpassText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.newpassText.borderStyle = UITextBorderStyleNone;
    self.newpassText.tag = 112;
    self.newpassText.secureTextEntry = YES;
    self.newpassText.delegate = self;
    [self.view addSubview:self.newpassText];
    
    self.confirmpsText = [[UITextField alloc] initWithFrame:CGRectMake(25, barViewHeight + 139, kScreen_Width - 45, 52)];
    self.confirmpsText.placeholder = NSLocalizedString(@"Confirm new password", nil);
    self.confirmpsText.font = [UIFont systemFontOfSize:16];
    self.confirmpsText.textAlignment = NSTextAlignmentLeft;
    self.confirmpsText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.confirmpsText.borderStyle = UITextBorderStyleNone;
    self.confirmpsText.tag = 113;
    self.confirmpsText.secureTextEntry = YES;
    self.confirmpsText.delegate = self;
    [self.view addSubview:self.confirmpsText];
    
    UILabel *showPwdLab = [[UILabel alloc] initWithFrame:CGRectMake(55, barViewHeight + 209, 120, 40)];
    showPwdLab.backgroundColor = [UIColor clearColor];
    showPwdLab.font = [UIFont systemFontOfSize:16];
    showPwdLab.text = NSLocalizedString(@"Show Password", nil);
    showPwdLab.textColor = [UIColor colorWithRed:151.0/255 green:151.0/255 blue:151.0/255 alpha:1];
    [self.view addSubview:showPwdLab];
    UITapGestureRecognizer *showPWDTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPasswordMethod)];
    showPwdLab.userInteractionEnabled = YES;
    [showPwdLab addGestureRecognizer:showPWDTap];
    
    butt = [UIButton buttonWithType:UIButtonTypeCustom];
    butt.frame = CGRectMake(20, barViewHeight + 216, 25, 25);
    [butt addTarget:self action:@selector(showPasswordMethod) forControlEvents:UIControlEventTouchUpInside];
    [butt setImage:[UIImage imageNamed:@"invalid.png"] forState:UIControlStateNormal];
    [self.view addSubview:butt];
}

- (void)leftButtonMethod:(UIButton *)but
{
    [self goBack];
}

- (void)reloadButtonMethod:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    if (self.oldPsText.text == nil || [self.oldPsText.text isEqualToString:@"" ]|| self.newpassText.text == nil || [self.newpassText.text isEqualToString:@"" ] ||self.confirmpsText.text == nil || [self.confirmpsText.text isEqualToString:@"" ]){
        [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:NSLocalizedString(@"Options can not be empty", nil)];
    } else {
        if (![self.oldPsText.text isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:KEY_PASSWORD]]) {
            [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:NSLocalizedString(@"Enter the correct password", nil)];
        } else {
            if (self.newpassText.text.length < 6 || self.confirmpsText.text.length < 6) {
                [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:NSLocalizedString(@"Pasword length must be longer than 6", nil)];
                return;
            }
            if ([self.newpassText.text isEqualToString:self.oldString]) {
                [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:NSLocalizedString(@"Enter the different password", nil)];
            } else {
                if (![self.newpassText.text isEqualToString:self.confirmpsText.text]) {
                    [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:NSLocalizedString(@"Entered password twice are different", nil)];
                } else {
                    
                    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
                    
                    [MMProgressHUD showWithTitle:NSLocalizedString(@"Links", nil) status:NSLocalizedString(@"Loading", nil)];
                    
                    
                    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERMODEL];
                    [self modifyPassWordRequestHttpToServerWithpsWord:self.oldPsText.text withNewpassWord:self.newpassText.text WithUserName:user];
                }
            }
        }
    }
}

- (void)modifyPassWordRequestHttpToServerWithpsWord:(NSString *)oldstr withNewpassWord:(NSString *)newPass WithUserName:(NSString *)username
{
    NSString *tempString =   [Util  getPassWordWithmd5:newPass];
    NSString *oldTemp = [Util getPassWordWithmd5:oldstr];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:AccessKey forKey:@"accessKey"];
    [dict setValue:username forKey:@"username"];
    [dict setValue:oldTemp forKey:@"old_password"];
    [dict setValue:tempString forKey:@"new_password"];
    
    [HTTPService POSTHttpToServerWith:ChangePSURL WithParameters:dict success:^(NSDictionary *dic) {
        
        NSString * success = [dic objectForKey:@"success"];
        [MMProgressHUD dismiss];
        
        if ([success boolValue] == true) {
            [MMProgressHUD dismiss];
            
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Change password successfully", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
            alert.tag = 237;
            [alert show];
        }
        if ([success boolValue] == false) {
            
//            [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:[dic objectForKey:@"msg"]];
            
        }
    } error:^(NSError *error) {
        
        [MMProgressHUD dismiss];
        
//        [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:NSLocalizedString(@"Link Timeout", nil)];
        
    }];
}

static bool isSelected = YES;
- (void)showPasswordMethod
{
    if (isSelected)
    {
        [butt setImage:[UIImage imageNamed:@"valid.png"] forState:UIControlStateNormal];
        self.oldPsText.secureTextEntry = NO;
        self.newpassText.secureTextEntry = NO;
        self.confirmpsText.secureTextEntry = NO;
        
    }else{
        
        [butt setImage:[UIImage imageNamed:@"invalid.png"] forState:UIControlStateNormal];
        self.oldPsText.secureTextEntry = YES;
        self.newpassText.secureTextEntry = YES;
        self.confirmpsText.secureTextEntry = YES;
    }
    isSelected = !isSelected;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
#pragma mark-
#pragma mark-<UITextFieldDelegate>
//return键
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}



//开始编辑
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    
    return YES;
}

//结束编辑
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 111) {
        
        self.oldString = textField.text;
    } else if (textField.tag == 112) {
        
        self.newpassString = textField.text;
    } else {
        
        self.confirmpassString = textField.text;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 237) {
        if (buttonIndex == 0) {
            
            [[NSUserDefaults standardUserDefaults]setObject:self.newpassString forKey:KEY_PASSWORD];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
//            [self goBack];
        }
    }
}

- (void)goBack
{
    [self.oldPsText setText:@""];
    [self.newpassText setText:@""];
    [self.confirmpsText setText:@""];
    [Util getAppDelegate].rootVC.selectedIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:@"flag"] intValue] - 1;
    [Util getAppDelegate].rootVC.tap.enabled = YES;
    [Util getAppDelegate].rootVC.pan.enabled = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [[Util getAppDelegate].rootVC.curView setFrame:CGRectMake(230, 0, kScreen_Width, kScreen_Height)];
    } completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
