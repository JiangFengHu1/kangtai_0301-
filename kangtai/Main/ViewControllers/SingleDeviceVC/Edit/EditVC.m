//
//
/**
 * Copyright (c) www.bugull.com
 */
//
//

#import "EditVC.h"
#import "VPImageCropperViewController.h"

#define HEIGHT_BUT ((([UIScreen mainScreen].bounds.size.width) > 320) ? 70 : ((([UIScreen mainScreen].bounds.size.height) > 480) ? 60 : 55))
#define WIDTH_BUT ((([UIScreen mainScreen].bounds.size.width) > 320) ? 70 : ((([UIScreen mainScreen].bounds.size.height) > 480) ? 60 : 55))
@interface EditVC () <UIAlertViewDelegate, VPImageCropperDelegate>
{
    NSDictionary *_UrlDictary;
    UIImageView *deleteImgView;
    NSInteger butIndex;
    int left;
    int right;
}


@property (nonatomic,copy)NSString *uuidString;
@property (nonatomic,strong)NSTimer *updateDeviceNameTimer;
@property (nonatomic,strong)NSTimer *updateDeviceImgTimer;

@property (nonatomic, strong) NSMutableArray *updateImgArr;
@property (nonatomic, strong) NSMutableArray *updateNameArr;

@end

@implementation EditVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    Device *device = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:self.macStr];
    [DeviceManagerInstance getDeviceInfoToMac:device.mac With:device.localContent WIthHost:device.host deviceType:device.deviceType];

    [RemoteServiceInstance getFirwareVersionNumberMAC:device.mac deviceType:device.deviceType];

    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _UrlDictary = [NSDictionary dictionary];
    self.updateImgArr = [[NSMutableArray alloc] initWithCapacity:0];
    self.updateNameArr = [[NSMutableArray alloc] initWithCapacity:1];
    self.dataModel = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:self.macStr];
    
    self.dataDAY = [[NSMutableArray alloc] initWithObjects:@"0.png",@"1.png",@"2.png",@"3.png",@"4.png",@"5.png",@"6.png",@"7.png",@"8.png",@"9.png",@"10.png",@"11.png", @"12.png",@"add_mark_normal.png",nil];
    
    // 判断当前设备的头像 是否包含在默认的头像数组中
    if (![self.dataDAY containsObject:self.dataModel.image]) {
        [self.dataDAY insertObject:self.dataModel.image atIndex:self.dataDAY.count - 1];
    }
    
    butIndex = 500 + [self.dataDAY indexOfObject:self.dataModel.image];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getNewsver:) name:@"getnewsver" object:nil];
    
    [self lodUI];
}

- (void)getNewsver:(NSNotification *)notification
{
    NSDictionary  *dict =[notification object];
    _UrlDictary = [NSDictionary dictionaryWithDictionary:dict];
    
    if ([self.dataModel.sver floatValue ] < [[dict objectForKey:@"sver"] floatValue]) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Find new version", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancle", nil) otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
        alert.tag = 112;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 112) {
        if (buttonIndex == 1) {
            
            for (int i = 0; i < 2; i++) {
                
                [DeviceManagerInstance firmwareUpgradeToDeviceMessageMac:self.dataModel.mac WIthHost:self.dataModel.host WithUrlLen:[[_UrlDictary objectForKey:@"urlLen"]intValue] WithUrl:[_UrlDictary objectForKey:@"urlData"] key:self.dataModel.key With:self.dataModel.localContent deviceType:self.dataModel.deviceType];
            }
            
            [self alertUIWith];
        }
    } else if (alertView.tag == 113) {

    }
}
- (void)alertUIWith
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Upgrade request has been sent.", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
    alert.tag = 113;
    [alert show];
}

- (void)lodUI
{
    self.titlelab.text = NSLocalizedString(@"Edit", nil);
    
    // 输入框
    float x = (kScreen_Width > 320) ? 45 : 30;
    float y = (kScreen_Width > 320) ? 50 : ((kScreen_Height == 480) ? 46 : 55);

    UIImageView *bgimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"input_squre.png"]];
    bgimage.frame = CGRectMake(x, barViewHeight + y, kScreen_Width - 2 * x, 7.5);;
    bgimage.userInteractionEnabled = YES;
    [self.view addSubview:bgimage];
    
    // 删除名字 图片
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(kScreen_Width - x - 20, barViewHeight + y - 16, 20, 20);
    [deleteBtn setImage:[UIImage imageNamed:@"word_del_normal.png"] forState:UIControlStateNormal];
    [deleteBtn setImage:[UIImage imageNamed:@"word_del_click.png"] forState:UIControlStateHighlighted];
    [deleteBtn addTarget:self action:@selector(deleteName:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteBtn];
    
    self.pwdText = [[UITextField alloc] initWithFrame:CGRectMake(x + 10, barViewHeight + y - 25, 205, 40)];
    self.pwdText.font = [UIFont systemFontOfSize:18];
    self.pwdText.textColor = RGBA(0.0, 170.0, 230.0, 1.0);
    self.pwdText.borderStyle = UITextBorderStyleNone;
    self.pwdText.text = self.dataModel.name;
    self.pwdText.delegate = self;
    self.pwdText.textAlignment = NSTextAlignmentLeft;
    self.pwdText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:self.pwdText];    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 45, kScreen_Width, 1)];
    lineView.backgroundColor = RGBA(210.0, 210.0, 210.0, 1.0);
//    [self.view addSubview:lineView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, barViewHeight + 2 *y - 26 + ((kScreen_Height == 480) ? 10 : 10), kScreen_Width, (kScreen_Width > 320) ? 460 : 370 + 4 * (y - 46))];
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.scrollView];
    
    self.imagev = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selecked_mark_circle.png"]];
    self.imagev.bounds = CGRectMake(0, 0, WIDTH_BUT + 8, HEIGHT_BUT + 8);
    self.imagev.layer.masksToBounds = YES;
    self.imagev.layer.cornerRadius = WIDTH_BUT / 2 + 4;
    self.imagev.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *overTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endInput)];
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:overTap];
    
    [self loadButtonMethod];
    
    NSString *firmwareStr = NSLocalizedString(@"Firmware version", nil);
    CGSize size = [Util sizeForText:firmwareStr Font:16 forWidth:320];
    UILabel *firmwareVersionLab = [[UILabel alloc] initWithFrame:CGRectMake(20, kScreen_Height - 30 - iOS_6_height, size.width, 20)];
    firmwareVersionLab.backgroundColor = [UIColor clearColor];
    firmwareVersionLab.text = firmwareStr;
    firmwareVersionLab.font = [UIFont systemFontOfSize:16];
    firmwareVersionLab.textColor = RGB(155, 155, 155);
    [self.view addSubview:firmwareVersionLab];
    
    Device *device = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:self.macStr];
    UILabel *versionLab = [[UILabel alloc] initWithFrame:CGRectMake(23 + size.width, kScreen_Height - 30 - iOS_6_height, kScreen_Width - 23 - size.width, 20)];
    versionLab.backgroundColor = [UIColor clearColor];
    versionLab.text = [NSString stringWithFormat:@": %@", device.sver];
    versionLab.font = [UIFont systemFontOfSize:16];
    versionLab.textColor = RGB(155, 155, 155);
    [self.view addSubview:versionLab];
}

- (void)deleteName:(UITapGestureRecognizer *)tap
{
    [self.pwdText becomeFirstResponder];
    if (self.pwdText.text != nil) {
        self.pwdText.text = nil;
    }
}

- (void)loadButtonMethod
{
    for (id view in [self.scrollView subviews])
    {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
        if ([view isKindOfClass:[UIImageView class]]){
            [view removeFromSuperview];
        }
    }
    [self.scrollView addSubview:self.imagev];

    float c = (kScreen_Width > 320) ? 330 : 300;
    float r = (kScreen_Width > 320) ? 200 : ((kScreen_Height == 480) ? 132 : 156);
    
    int col = (c - HEIGHT_BUT * 3)/4;
    int row = (r - WIDTH_BUT * 2)/3;
    
    NSLog(@"=== %lu %@",(unsigned long)self.dataDAY.count, self.dataDAY);
    
    for (int i = 0; i < [self.dataDAY count]; i ++)
    {
        int x = col + i%3 *(col + HEIGHT_BUT) + ((kScreen_Width > 320) ? ((kScreen_Width > 375) ? 40 : 20) : 10);
        int y = row + i/3 *(row + WIDTH_BUT) - ((kScreen_Height == 480) ? 3 : 8);
        
        NSString *imageName = [self.dataDAY objectAtIndex:i];
        
        UIImage *endImage;
        NSString *dataPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:[NSString stringWithFormat:@"/%@",imageName]];//获取程序包中相应文件的路径
        NSFileManager *fileMa = [NSFileManager defaultManager];
        
        if(![fileMa fileExistsAtPath:dataPath]){
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:[Util getFilePathWithImageName:imageName]]) {
                NSLog(@"找不到图片");
                
            }else{
                endImage = [[UIImage alloc] initWithContentsOfFile:[Util getFilePathWithImageName:imageName]];
//                butIndex = self.dataDAY.count - 1;
                
            }
            
        }else{
            endImage = [UIImage imageNamed:imageName];
            
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:endImage];
        imageView.frame = CGRectMake(x, y , WIDTH_BUT, HEIGHT_BUT);
        imageView.userInteractionEnabled = YES;
        imageView.layer.cornerRadius = WIDTH_BUT / 2;
        imageView.clipsToBounds = YES;
        
        imageView.tag = i + 600;
        [self.scrollView addSubview:imageView];
        
        UIButton *but =[UIButton buttonWithType:UIButtonTypeCustom];
        but.frame = CGRectMake(x, y, WIDTH_BUT, HEIGHT_BUT);
        but.tag = i + 500;
        
        NSInteger heightIn = 1;
        if (self.editstateType != EditStateRFpush) {
            if ([self.dataDAY containsObject:self.dataModel.image]) {
                
                heightIn = [self.dataDAY indexOfObject:self.dataModel.image];
            }
        }
        if (heightIn == but.tag - 500) {
            
            self.imagev.center = but.center;
//            butIndex = but.tag;
        }
        
        [but addTarget:self action:@selector(circleButtonMethod:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.scrollView addSubview:but];
    }
}

- (void)endInput
{
    [self.view endEditing:YES];
}

#pragma mark-点击方法
- (void)circleButtonMethod:(UIButton *)but
{
    [self.view endEditing:YES];
    self.editstateType = 3;
    self.imagev.hidden = NO;
    int last = (int)self.dataDAY.count - 1+500;
    if (but.tag == last) {
        [self actionSheet];
    } else {
        self.imagev.center = but.center;
        butIndex = but.tag;
    }
}

- (void)leftButtonMethod:(UIButton *)but
{
//    back = 1;
    [self.navigationController popViewControllerAnimated:YES];
}

static bool is_same;
- (void)reloadButtonMethod:(UIButton *)but
{
    [self textFieldDidEndEditing:self.pwdText];
//    NSLog(@"==%lu%d %d"(unsigned long), self.dataDAY.count, butIndex);
    
//    back = 2;
    NSString *imageNe = [self.dataDAY objectAtIndex:butIndex-500];
    NSString *string;
    if (butIndex - 500 == self.dataDAY.count - 2 && self.dataDAY.count > 14 && ![imageNe isEqualToString:self.dataModel.image]) {
        string = self.uuidString;
        if ([string hasPrefix:@".png"]) {
            
            string = [string stringByAppendingString:@".png"];
        }
    } else {
        string = imageNe;
    }
    
    is_same = [string isEqualToString:self.dataModel.image];

    if (self.editstateType != EditStateRFpush) {
        if (self.dName == nil || [self.dName isEqualToString:@""]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Device name can not be empty", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }  else {
            self.dataModel.name = self.dName;
            self.dataModel.image = [self.dataDAY objectAtIndex:butIndex-500];
            if (self.dataModel != nil) {
                [[DeviceManagerInstance getlocalDeviceDictary] setObject:self.dataModel forKey:self.dataModel.macString];
            }
            
            [DataBase updataName:self.dataModel.name where:self.dataModel.macString];
            [DataBase updataToDataBaseWithimageName:self.dataModel.image where:self.dataModel.macString];
            
            // 编辑完成上传服务器
            [self editWifiDeviceSendToServer:self.dataModel WithNewImageName:string];
            // 输入名字和设备原来名字一致的话 不操作
        }
    }

    UIImage *endImage;
    // 假如上传的头像名与设备当前的头像名一致  则不操作
    if (!is_same) {
        if (butIndex - 500 == self.dataDAY.count - 2 && self.dataDAY.count > 14) {
            endImage = [[UIImage alloc] initWithContentsOfFile:[Util getFilePathWithImageName:imageNe]];
        }
        else{
            endImage = [UIImage imageNamed:imageNe];
        }
        // 上传图片
        [self sendImageToServerWithimageName:string WithImage:endImage];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark-textFieldDelegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    if ((textField.text != nil || ![textField.text isEqualToString:@""]) && back == 2) {
//        self.dataModel.name = textField.text;
//    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text != nil || ![textField.text isEqualToString:@""]) {
        
        self.dName = textField.text;
    }
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

#pragma mark-图片
- (void)actionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Photos",nil), NSLocalizedString(@"Camera",nil), nil ];
    [actionSheet showInView:self.view];//参数指显示UIActionSheet的parent。
}

-(void) actionSheet : (UIActionSheet *) actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self pickImageFromAlbum];
            break;
        case 1:
            [self pickImageFromCamera];
            break;
        default:
            break;
    }
}
#pragma mark-
#pragma mark - imagePicker
- (void)pickImageFromAlbum
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
    [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
    controller.mediaTypes = mediaTypes;
    controller.delegate = self;
    [self presentViewController:controller
                       animated:YES
                     completion:^(void){
                         NSLog(@"Picker View Controller is presented");
                     }];

}

- (void)pickImageFromCamera
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tips",nil) message:NSLocalizedString(@"Current camera unavailable", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
    [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
    controller.mediaTypes = mediaTypes;
    controller.delegate = self;
    [self presentViewController:controller
                       animated:YES
                     completion:^(void){
                         NSLog(@"Picker View Controller is presented");
                     }];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:NO completion:^() {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        //对图片大小进行压缩--
        image = [self imageByScalingToMaxSize:image];
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            UIImageWriteToSavedPhotosAlbum (image, nil, nil , nil);    //保存到library
        }
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:image cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        imgEditorVC.view.backgroundColor = [UIColor clearColor];
        [self presentViewController:imgEditorVC animated:NO completion:nil];
    }];
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH)
    {
        return sourceImage;
    }
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    CGSize imagesize = editedImage.size;
    imagesize.height =200;
    imagesize.width =200;
    //对图片大小进行压缩--
    editedImage = [self imageWithImage:editedImage scaledToSize:imagesize];

    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
        UIImageView *imgView = (UIImageView *)[self.view viewWithTag:600 + self.dataDAY.count - 1 ];
        imgView.image = editedImage;
        NSData *imageData = UIImageJPEGRepresentation(editedImage, 0.00001);
        [imageData writeToFile:[self getFilePath] atomically:YES];
        [self loadButtonMethod];
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}

-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (NSString *)getFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *tempStr = [Util getUUID];
    
    tempStr = [tempStr stringByAppendingString:@".png"];
    self.uuidString = tempStr;
    // 确保头像数组最大个数为15
    if (self.dataDAY.count == 14) {
        
        [self.dataDAY insertObject:tempStr atIndex:self.dataDAY.count - 1];
    }
    if (self.dataDAY.count == 15) {
        if ([self.dataModel.image isEqualToString:[self.dataDAY objectAtIndex:self.dataDAY.count - 2]]) {
            self.imagev.hidden = YES;
        }
        [self.dataDAY replaceObjectAtIndex:self.dataDAY.count -2 withObject:tempStr];
    }
//    if (self.dataDAY.count == 15 && i == 0) {
//        
//        [self.dataDAY replaceObjectAtIndex:self.dataDAY.count -2 withObject:tempStr];
//        i = 1;
//    }

    return [docDir stringByAppendingString:[NSString stringWithFormat:@"/%@",tempStr]];
}


#pragma mark-HTTP

//编辑 WIFI 设备

- (void)editWifiDeviceSendToServer:(Device *)devices_ WithNewImageName:(NSString *)imageName
{
    [self.updateNameArr removeAllObjects];
    [self.updateNameArr addObject:devices_];
    [self.updateNameArr addObject:imageName];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *tempString = [Util getPassWordWithmd5:[defaults objectForKey:KEY_PASSWORD]];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:AccessKey forKey:@"accessKey"];
    [dict setValue:[defaults objectForKey:KEY_USERMODEL] forKey:@"username"];
    [dict setValue:tempString forKey:@"password"];
    [dict setValue:[devices_.macString uppercaseStringWithLocale:[NSLocale currentLocale]]   forKey:@"macAddress"];
    [dict setValue:devices_.name forKey:@"deviceName"];
    [dict setValue:devices_.codeString  forKey:@"companyCode"];
    [dict setValue:devices_.deviceType forKey:@"deviceType"];
    [dict setValue:devices_.authCodeString forKey:@"authCode"];
    [dict setValue:devices_.image forKey:@"imageName"];
    
    
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)devices_.orderNumber] forKey:@"orderNumber"];
    NSString *timeSp = [NSString stringWithFormat:@"%f", (double)[[NSDate date] timeIntervalSince1970]*1000];
    
    NSArray *temp =   [timeSp componentsSeparatedByString:@"."];
    [dict setValue:[temp objectAtIndex:0] forKey:@"lastOperation"];
    
    [HTTPService POSTHttpToServerWith:EditWifiURL WithParameters:dict   success:^(NSDictionary *dic) {
        
        NSLog(@"dicfssr=====%@",dic);
        
        [MMProgressHUD dismiss];
        
        NSString * success = [dic objectForKey:@"success"];
        
        if ([success boolValue] == true) {
            NSLog(@"设备名修改成功");
            
        }
        if ([success boolValue] == false) {
            
//            [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:[dic objectForKey:@"msg"]];
        }
    } error:^(NSError *error) {
        [MMProgressHUD dismiss];
        NSLog(@"设备名修改失败");
        
//        [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:NSLocalizedString(@"Link Timeout", nil)];
    }];
}

- (NSString *)changeImageName:(NSString *)imageNe
{
    UInt8 byte[6];
    for (int i = 0; i < 6; i ++){
        byte[i] = arc4random() % 0xff;
    }
    
    NSString *tempName = [NSString stringWithFormat:@"WIFI-%d%d%d%d%d%d",byte[0],byte[1],byte[2],byte[3],byte[4],byte[5]];
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *nameString = [tempName stringByAppendingString:timeSp];
    
    return nameString;
}

- (void)sendImageToServerWithimageName:(NSString *)name WithImage:(UIImage *)image
{
    [self.updateNameArr removeAllObjects];
    [self.updateNameArr addObject:name];
    [self.updateNameArr addObject:image];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tempString = [Util getPassWordWithmd5:[defaults objectForKey:KEY_PASSWORD]];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:AccessKey forKey:@"accessKey"];
    [dict setValue:[defaults objectForKey:KEY_USERMODEL] forKey:@"username"];
    [dict setValue:tempString forKey:@"password"];
    [dict setValue:name forKey:@"imageName"];
    
    [HTTPService PostHttpToServerImageAndDataWith:UploadURL WithParmeters:dict WithFilePath:nil imageName:name andImageFile:image success:^(NSDictionary *dic) {
        
        NSString * success = [dic objectForKey:@"success"];
        NSLog(@"dic == %@",dic);
        
        if ([success boolValue] == true) {
            [self.updateDeviceImgTimer invalidate];
            self.updateDeviceImgTimer = nil;
            NSLog(@"图片上传成功");
            
            NSLog(@"dic == %@",dic);
            
        }
        if ([success boolValue] == false) {
            
//            [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:[dic objectForKey:@"msg"]];
            
        }
    } error:^(NSError *error) {
        [MMProgressHUD dismiss];
        NSLog(@"图片上传失败");
        
//        [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:NSLocalizedString(@"Link Timeout", nil)];
    }];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
