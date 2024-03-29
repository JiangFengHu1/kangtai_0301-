//
//  AddNewRFDeviceVC.m
//  kangtai
//
//  Created by 张群 on 14/12/15.
//
//

#import "AddNewRFDeviceVC.h"

#define HEIGHT_BUT ((([UIScreen mainScreen].bounds.size.width) > 320) ? 70 : ((([UIScreen mainScreen].bounds.size.height) > 480) ? 55 : 50))
#define WIDTH_BUT ((([UIScreen mainScreen].bounds.size.width) > 320) ? 70 : ((([UIScreen mainScreen].bounds.size.height) > 480) ? 55 : 50))

@interface AddNewRFDeviceVC () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UIImageView *inputImgView;
    UITextField *nameTF;
    NSString *deviceNameStr;
    UIButton *typeBtn;
    UIButton *nearestBtn;
    UIImageView *typeImgView;
    UIImageView *nearestImgView;
    UIImageView *selectedMark;
    UIView *iconView;
    UIView *typeView;
    UIView *nearestView;
    UIView *bgView;
    NSMutableArray *iconArr;
    NSMutableArray *iconClickedArr;
    NSMutableArray *typeArr;
    UIImagePickerController *imagePicker;
    UITableView *wifiDeviceTableView;
    
    int orderNumber;
    int btnTag;
    int rfMacTag;
    int typeButIndex;
    int clicked;
    BOOL isIphone4;
}
@end

@implementation AddNewRFDeviceVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
        
    if (self.RFMacStrArr.count != 0) {
        [wifiDeviceTableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initVariable];
    [self initUI];
}

#pragma mark - initVariable & initUI
- (void)initVariable
{
    clicked = 1;
    
    Device *device = nil;
    if (self.RFMacStrArr.count != 0) {
        device = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:(self.typeNumber == 1) ? self.macStr : self.RFMacStrArr[0]];
    }
    deviceNameStr = (self.RFMacStrArr.count == 0) ? NSLocalizedString(@"No WiFi device with RF function", nil) : device.name;

    isIphone4 = (kScreen_Height == 480);
    orderNumber = 1;
    
    if (self.fmdbRFTableArray.count != 0) {
        for (RFDataModel *model in self.fmdbRFTableArray) {
            orderNumber = MAX(orderNumber, (int)model.orderNumber);
        }
    }
    
    iconArr = [NSMutableArray arrayWithObjects: @"13.png", @"14.png", @"15.png", @"16.png", @"17.png", @"18.png", @"19.png", @"20.png", @"add_mark_normal.png", nil];
    
    if (self.typeNumber == 1) {
        if (![iconArr containsObject:self.model.rfDataLogo]) {
            if (self.model.rfDataLogo.length != 0) {
                [iconArr insertObject:self.model.rfDataLogo atIndex:iconArr.count - 1];
                btnTag = 1007;
            } else {
                btnTag = 1000;
            }
        } else {
            btnTag = (int)[iconArr indexOfObject:self.model.rfDataLogo] + 1000;
        }
    }
    typeArr = [NSMutableArray arrayWithObjects:NSLocalizedString(@"Switch", nil), NSLocalizedString(@"Dimmer", nil), NSLocalizedString(@"Curtain", nil), NSLocalizedString(@"Thermostat", nil), nil];
}

- (void)initUI
{
    if (self.typeNumber == 1) {
        self.titlelab.text = NSLocalizedString(@"Edit RF device", nil);
    } else {
        self.titlelab.text = NSLocalizedString(@"Add RF device", nil);
    }
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    bgView.backgroundColor = RGB(100, 100, 100);
    bgView.alpha = .8f;
    bgView.hidden = YES;
    [self.view addSubview:bgView];
    
    typeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width - 80, 270)];
    typeView.layer.cornerRadius = 10;
    typeView.center = self.view.center;
    typeView.hidden = YES;
    typeView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:typeView];
    
    UILabel *deviceTypelab = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, typeView.frame.size.width, 20)];
    deviceTypelab.backgroundColor = [UIColor clearColor];
    deviceTypelab.textColor = RGB(100, 100, 100);
    deviceTypelab.textAlignment = NSTextAlignmentCenter;
    deviceTypelab.text = NSLocalizedString(@"Device type", nil);
    [typeView addSubview:deviceTypelab];
    
    CGSize size;
    for (int i = 0; i < 4; i++) {
        UIButton *typeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        typeButton.frame = CGRectMake(0, 50 + i * 50, typeView.frame.size.width, 50);
        typeButton.tag = 100 + i;
        [typeButton addTarget:self action:@selector(chooseType:) forControlEvents:UIControlEventTouchUpInside];
        [typeView addSubview:typeButton];
        
        size = [Util sizeForText:typeArr[i] Font:16 forWidth:320];
        UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, size.width, 20)];
        typeLabel.backgroundColor = [UIColor clearColor];
        typeLabel.tag = 300 + i;
        typeLabel.font = [UIFont systemFontOfSize:16];
        typeLabel.textColor = RGB(100, 100, 100);
        typeLabel.text = typeArr[i];
        [typeButton addSubview:typeLabel];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(typeButton.frame.size.width - 40, 12, 26, 26)];
        imgView.layer.cornerRadius = 13;
        imgView.tag = 200 + i;
        imgView.image = [UIImage imageNamed:@"invalid_2"];
        if (i == 0 && self.typeNumber == 2) {
            imgView.image = [UIImage imageNamed:@"valid_2"];
            typeButIndex = i;
        } else if (self.typeNumber == 1 && i == [self.typeStr intValue] - 1) {
            imgView.image = [UIImage imageNamed:@"valid_2"];
            typeButIndex = i;
        }
        [typeButton addSubview:imgView];
    }
    
    
    nearestView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width - 80, 70 + 50 * ((self.RFMacStrArr.count > 4) ? 4 : self.RFMacStrArr.count))];
    nearestView.layer.cornerRadius = 10;
    nearestView.center = self.view.center;
    nearestView.hidden = YES;
    nearestView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:nearestView];
    
    UILabel *nearestDeviceLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, typeView.frame.size.width, 20)];
    nearestDeviceLab.backgroundColor = [UIColor clearColor];
    [nearestDeviceLab setAdjustsFontSizeToFitWidth:YES];
    nearestDeviceLab.textColor = RGB(100, 100, 100);
    nearestDeviceLab.textAlignment = NSTextAlignmentCenter;
    nearestDeviceLab.text = NSLocalizedString(@"The nearest WiFi device", nil);
    [nearestView addSubview:nearestDeviceLab];
    
    wifiDeviceTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, typeView.frame.size.width, 50 * ((self.RFMacStrArr.count > 4) ? 4 : self.RFMacStrArr.count)) style:UITableViewStylePlain];
    wifiDeviceTableView.delegate = self;
    wifiDeviceTableView.dataSource = self;
    wifiDeviceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [nearestView addSubview:wifiDeviceTableView];

    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, barViewHeight, 100 * widthScale, kScreen_Height - barViewHeight)];
    leftView.backgroundColor = RGB(235, 235, 235);
    [self.view addSubview:leftView];
    
    size = [Util sizeForText:NSLocalizedString(@"Name", nil) Font:16 forWidth:leftView.frame.size.width];
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, barViewHeight + (isIphone4 ? 40 : 50), size.width, size.height)];
    nameLab.backgroundColor = [UIColor clearColor];
    nameLab.numberOfLines = 0;
    nameLab.font = [UIFont systemFontOfSize:16];
    nameLab.adjustsFontSizeToFitWidth = YES;
    nameLab.center = CGPointMake(leftView.center.x, nameLab.center.y);
    nameLab.text = NSLocalizedString(@"Name", nil);
    nameLab.textColor = RGB(50, 50, 50);
    [self.view addSubview:nameLab];
    
    size = [Util sizeForText:NSLocalizedString(@"Type", nil) Font:16 forWidth:leftView.frame.size.width];
    UILabel *typeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, barViewHeight + (isIphone4 ? 90 : 120), size.width, size.height)];
    typeLab.backgroundColor = [UIColor clearColor];
    typeLab.numberOfLines = 0;
    typeLab.font = [UIFont systemFontOfSize:16];
    typeLab.adjustsFontSizeToFitWidth = YES;
    typeLab.center = CGPointMake(leftView.center.x, typeLab.center.y);
    typeLab.text = NSLocalizedString(@"Type", nil);
    typeLab.textColor = RGB(50, 50, 50);
    [self.view addSubview:typeLab];
    
    size = [Util sizeForText:NSLocalizedString(@"WiFi Device", nil) Font:16 forWidth:leftView.frame.size.width];
    UILabel *WIFILab = [[UILabel alloc] initWithFrame:CGRectMake(0, barViewHeight + (isIphone4 ? 145 : 190), size.width, size.height)];
    WIFILab.backgroundColor = [UIColor clearColor];
    WIFILab.numberOfLines = 0;
    WIFILab.font = [UIFont systemFontOfSize:16];
    WIFILab.adjustsFontSizeToFitWidth = YES;
    WIFILab.center = CGPointMake(leftView.center.x, WIFILab.center.y);
    WIFILab.text = NSLocalizedString(@"WiFi Device", nil);
    WIFILab.textColor = RGB(50, 50, 50);
    [self.view addSubview:WIFILab];
    
    size = [Util sizeForText:NSLocalizedString(@"Icon", nil) Font:16 forWidth:leftView.frame.size.width];
    UILabel *iconLab = [[UILabel alloc] initWithFrame:CGRectMake(0, WIFILab.frame.origin.y + WIFILab.frame.size.height + (kScreen_Height - WIFILab.frame.origin.y - WIFILab.frame.size.height) / 2, size.width, size.height)];
    iconLab.backgroundColor = [UIColor clearColor];
    iconLab.numberOfLines = 0;
    iconLab.font = [UIFont systemFontOfSize:16];
    iconLab.adjustsFontSizeToFitWidth = YES;
    iconLab.center = CGPointMake(leftView.center.x, iconLab.center.y);
    iconLab.text = NSLocalizedString(@"Icon", nil);
    iconLab.textColor = RGB(50, 50, 50);
    [self.view addSubview:iconLab];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(leftView.frame.size.width + leftView.frame.origin.x, barViewHeight, kScreen_Width - (leftView.frame.size.width + leftView.frame.origin.x), kScreen_Height - barViewHeight)];
    v.backgroundColor = [UIColor clearColor];
    [self.view addSubview:v];
    inputImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (isIphone4 ? 47 : 57), v.frame.size.width - 30, 7.5)];
    inputImgView.image = [UIImage imageNamed:@"input_squre.png"];
    [v addSubview:inputImgView];
    nameTF = [[UITextField alloc] initWithFrame:CGRectMake(25, (isIphone4 ? 25 : 35), inputImgView.frame.size.width - 15, 30)];
    nameTF.delegate = self;
    nameTF.textColor = RGB(0, 160, 230);
    if (self.typeNumber == 1) {
        nameTF.text = self.nameStr;
    } else {
        nameTF.text = @"";
    }
    [v addSubview:nameTF];
    
    size = [Util sizeForText:NSLocalizedString((self.typeNumber == 1) ? [typeArr objectAtIndex:[self.typeStr intValue] - 1] : @"Switch", nil) Font:16 forWidth:320];
    typeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    typeBtn.frame = CGRectMake(20, (isIphone4 ? 92 : 122), size.width, size.height);
    typeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [typeBtn setTitle:NSLocalizedString((self.typeNumber == 1) ? [typeArr objectAtIndex:[self.typeStr intValue] - 1] : @"Switch", nil) forState:UIControlStateNormal];
    [typeBtn setTitleColor:RGB(0, 160, 230) forState:UIControlStateNormal];
    [typeBtn addTarget:self action:@selector(showTypeView) forControlEvents:UIControlEventTouchUpInside];
    [v addSubview:typeBtn];
    typeImgView = [[UIImageView alloc] initWithFrame:CGRectMake(23+size.width, (isIphone4 ? 97 : 127), 13, 10)];
    typeImgView.image = [UIImage imageNamed:@"sjx_normal"];
    [v addSubview:typeImgView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, typeBtn.frame.origin.y + (isIphone4 ? 35 : 45), v.frame.size.width, 1)];
    line.backgroundColor = RGB(210, 210, 210);
    [v addSubview:line];
    
    size = [Util sizeForText:deviceNameStr Font:16 forWidth:320];
    nearestBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nearestBtn.frame = CGRectMake(20, (isIphone4 ? 147 : 192), size.width, size.height);
    nearestBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [nearestBtn setTitle:deviceNameStr forState:UIControlStateNormal];
    [nearestBtn setTitleColor:RGB(0, 160, 230) forState:UIControlStateNormal];
    [nearestBtn addTarget:self action:@selector(showNearestWiFiDeviceView) forControlEvents:UIControlEventTouchUpInside];
    nearestBtn.userInteractionEnabled = (self.RFMacStrArr.count != 0);
    [v addSubview:nearestBtn];
    nearestImgView = [[UIImageView alloc] initWithFrame:CGRectMake(23+size.width, (isIphone4 ? 152 : 197), 13, 10)];
    nearestImgView.image = [UIImage imageNamed:@"sjx_normal"];
    nearestImgView.hidden = (self.RFMacStrArr.count == 0);
    [v addSubview:nearestImgView];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0, nearestBtn.frame.origin.y + (isIphone4 ? 35 : 45), v.frame.size.width, 1)];
    line.backgroundColor = RGB(210, 210, 210);
    [v addSubview:line];
    
    iconView = [[UIView alloc] initWithFrame:CGRectMake(0, (isIphone4 ? 205 : 250), v.frame.size.width, v.frame.size.height - (isIphone4 ? 205 : 250))];
    iconView.backgroundColor = [UIColor clearColor];
    [v addSubview:iconView];
    
    selectedMark = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_BUT + 8, HEIGHT_BUT + 8)];
    selectedMark.image = [UIImage imageNamed:@"selecked_mark_circle"];
    selectedMark.layer.masksToBounds = YES;
    selectedMark.layer.cornerRadius = WIDTH_BUT / 2 + 4;
    
    [self loadIconButton];
}

#pragma mark - loadIconButton
- (void)loadIconButton
{
    [iconView removeSubViews];
    [iconView addSubview:selectedMark];
    
    for (int i = 0 ; i < iconArr.count; i++) {
        UIButton *iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        iconBtn.frame = CGRectMake(10 + (iconView.frame.size.width - 9)/ 3 * (i % 3), 0 + i / 3 * (HEIGHT_BUT + (isIphone4 ? 3 : 8)) , WIDTH_BUT, HEIGHT_BUT);
        iconBtn.layer.masksToBounds = YES;
        iconBtn.layer.cornerRadius = WIDTH_BUT / 2;
        iconBtn.tag = 1000 + i;
        NSString *imageName = [iconArr objectAtIndex:i];
        
        UIImage *endImage;
        NSString *dataPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:[NSString stringWithFormat:@"/%@",imageName]];//获取程序包中相应文件的路径
        NSFileManager *fileMa = [NSFileManager defaultManager];
        
        if(![fileMa fileExistsAtPath:dataPath]){
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:[Util getFilePathWithImageName:imageName]]) {
                NSLog(@"找不到图片");
                
            }else{
                endImage = [[UIImage alloc] initWithContentsOfFile:[Util getFilePathWithImageName:imageName]];
            }
            
        }else{
            endImage = [UIImage imageNamed:imageName];
        }

        
        [iconBtn setBackgroundImage:endImage forState:UIControlStateNormal];
        [iconBtn setBackgroundImage:endImage forState:UIControlStateHighlighted];
        if (i == iconArr.count - 1) {
            [iconBtn setBackgroundImage:[UIImage imageNamed:@"add_mark_click"] forState:UIControlStateHighlighted];
        }
        if (self.typeNumber == 1) {
            if (self.model.rfDataLogo.length != 0) {
                if ([[iconArr objectAtIndex:i] isEqualToString:self.model.rfDataLogo])  {
                }
            } else {
                if (i == 0) {
                    selectedMark.center = iconBtn.center;
                }
            }
        } else {
            if (i == 0) {
                selectedMark.center = iconBtn.center;
                btnTag = (int)iconBtn.tag;
            }
        }
        
        [iconBtn addTarget:self action:@selector(chooseDeviceIcon:) forControlEvents:UIControlEventTouchUpInside];
        [iconView addSubview:iconBtn];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.RFMacStrArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    WiFiDeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[WiFiDeviceListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.tag = 800 + indexPath.row;
    
    
    Device *device = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:self.RFMacStrArr[indexPath.row]];
    cell.nearestLabel.text = device.name;
    
    if (clicked == 1) {
        if (self.typeNumber == 2) {
            if (indexPath.row == 0 ) {
                rfMacTag = 0;
                cell.imgView.image = [UIImage imageNamed:@"valid_2"];
            } else {
                cell.imgView.image = [UIImage imageNamed:@"invalid_2"];
            }

        } else if (self.typeNumber == 1) {
            if ([self.RFMacStrArr[indexPath.row] isEqualToString:self.macStr]) {
                rfMacTag = (int)indexPath.row;
                cell.imgView.image = [UIImage imageNamed:@"valid_2"];
            } else {
                cell.imgView.image = [UIImage imageNamed:@"invalid_2"];
            }
        }
    } else {
        if (indexPath.row == clicked - 10) {
            rfMacTag = (int)indexPath.row;
            cell.imgView.image = [UIImage imageNamed:@"valid_2"];
        } else {
            cell.imgView.image = [UIImage imageNamed:@"invalid_2"];
        }
    }
    
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    clicked = (int)indexPath.row + 10;
    
    WiFiDeviceListCell *cell = (WiFiDeviceListCell *)[self.view viewWithTag:800 + indexPath.row];
    
    CGSize size = [Util sizeForText:cell.nearestLabel.text Font:16 forWidth:320];
    [nearestBtn setTitle:cell.nearestLabel.text forState:UIControlStateNormal];
    nearestBtn.frame = CGRectMake(20, (isIphone4 ? 147 : 192), size.width, size.height);
    nearestImgView.frame =  CGRectMake(23+size.width, (isIphone4 ? 152 : 197), 13, 10);
    
    bgView.hidden = YES;
    nearestView.hidden = YES;
    
    [wifiDeviceTableView reloadData];
}

#pragma mark - the touch event on self.view
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    bgView.hidden = YES;
    typeView.hidden = YES;
    nearestView.hidden = YES;
}

#pragma mark - showTypeView & showNearestWiFiDeviceView
- (void)showTypeView
{
    typeImgView.image = [UIImage imageNamed:@"sjx_click"];
    [self performSelector:@selector(backToNormalStatus:) withObject:@"type" afterDelay:.1f];
    bgView.hidden = NO;
    typeView.hidden = NO;
    [self.view bringSubviewToFront:bgView];
    [self.view bringSubviewToFront:typeView];
}

- (void)showNearestWiFiDeviceView
{
    nearestImgView.image = [UIImage imageNamed:@"sjx_click"];
    [self performSelector:@selector(backToNormalStatus:) withObject:@"nearest" afterDelay:.1f];
    bgView.hidden = NO;
    nearestView.hidden = NO;
    [self.view bringSubviewToFront:bgView];
    [self.view bringSubviewToFront:nearestView];
}

#pragma mark - chooseDeviceIcon
- (void)chooseDeviceIcon:(UIButton *)btn
{
    if (btn.tag == 1000 + iconArr.count - 1) {
        [self showActionSheet];
    } else {
        selectedMark.center = btn.center;
        btnTag = (int)btn.tag;
    }
}

#pragma mark - showActionSheet
- (void)showActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Photos", nil), NSLocalizedString(@"Camera", nil), nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
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

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.RFNameStr = textField.text;
}

#pragma mark - imagePicker
- (void)pickImageFromAlbum
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePicker.allowsEditing = YES;
    
    //    [self presentViewController:imagePicker animated:YES completion:nil];
    
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
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePicker.allowsEditing = YES;
    
    //    [self presentViewController:imagePicker animated:YES completion:nil];
    
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
        UIButton *btn = (UIButton *)[self.view viewWithTag:1000 + iconArr.count - 1];
        [btn setBackgroundImage:editedImage forState:UIControlStateNormal];
        [btn setBackgroundImage:editedImage forState:UIControlStateHighlighted];
        NSData *imageData = UIImageJPEGRepresentation(editedImage, 0.00001);
        [imageData writeToFile:[self getFilePath] atomically:YES];
        [self loadIconButton];
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
    self.uuidStr = tempStr;
    // 确保头像数组最大个数为10
    //    NSLog(@"=== %d",self.dataDAY.count);
    int i = 0;
    if (iconArr.count == 9) {
        
        [iconArr insertObject:tempStr atIndex:iconArr.count - 1];
    }
    if (iconArr.count == 10 && i == 0) {
        
        [iconArr replaceObjectAtIndex:iconArr.count -2 withObject:tempStr];
        i = 1;
    }
    
    return [docDir stringByAppendingString:[NSString stringWithFormat:@"/%@",tempStr]];
}

#pragma mark - chooseType
- (void)chooseType:(UIButton *)btn
{
    for (int i = 0; i < 4; i++) {
        UIImageView *tempImgView = (UIImageView *)[self.view viewWithTag:200 + i];
        if (i == btn.tag - 100) {
            tempImgView.image = [UIImage imageNamed:@"valid_2"];
            typeButIndex = i;
        } else {
            tempImgView.image = [UIImage imageNamed:@"invalid_2"];
        }
    }
    bgView.hidden = YES;
    typeView.hidden = YES;
    
    UILabel *tempLab = (UILabel *)[self.view viewWithTag:300 + btn.tag - 100];
    CGSize size = [Util sizeForText:tempLab.text Font:16 forWidth:320];
    [typeBtn setTitle:tempLab.text forState:UIControlStateNormal];
    typeBtn.frame = CGRectMake(20, (isIphone4 ? 92 : 122), size.width, size.height);
    typeImgView.frame = CGRectMake(23+size.width, (isIphone4 ? 97 : 127), 13, 10);
}

#pragma mark - chooseNearestWiFiDevice
- (void)chooseNearestWiFiDevice:(UIButton *)btn
{
    for (int i = 0; i < self.RFMacStrArr.count; i++) {
        UIImageView *tempImgView = (UIImageView *)[self.view viewWithTag:600 + i];
        if (i == btn.tag - 400) {
            rfMacTag = i;
            tempImgView.image = [UIImage imageNamed:@"valid_2"];
        } else {
            tempImgView.image = [UIImage imageNamed:@"invalid_2"];
        }
    }
    bgView.hidden = YES;
    nearestView.hidden = YES;
    
    UILabel *tempLab = (UILabel *)[self.view viewWithTag:500 + btn.tag - 400];
    CGSize size = [Util sizeForText:tempLab.text Font:16 forWidth:320];
    [nearestBtn setTitle:tempLab.text forState:UIControlStateNormal];
    nearestBtn.frame = CGRectMake(20, (isIphone4 ? 147 : 192), size.width, size.height);
    nearestImgView.frame =  CGRectMake(23+size.width, (isIphone4 ? 152 : 197), 13, 10);
}

#pragma mark - backToNormalStatus
- (void)backToNormalStatus:(NSString *)str
{
    if ([str isEqualToString:@"type"]) {
        typeImgView.image = [UIImage imageNamed:@"sjx_normal"];
    } else {
        nearestImgView.image = [UIImage imageNamed:@"sjx_normal"];
    }
}

#pragma mark - navBtn method
-(void)leftButtonMethod:(UIButton *)but
{
    if (self.typeNumber != 1) {
        [Util getAppDelegate].rootVC.pan.enabled = YES;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)reloadButtonMethod:(UIButton *)sender
{
    [self textFieldDidEndEditing:nameTF];
    if (self.RFNameStr == nil || [self.RFNameStr isEqualToString:@""]) {
        [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:NSLocalizedString(@"RF device name can not be empty", nil)];
        return;
    }
    
    if (self.RFMacStrArr.count == 0) {
        
        [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:NSLocalizedString(@"No WiFi device with RF function", nil)];
        return;
    }
    
    Device *dev = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:self.RFMacStrArr[rfMacTag]];
    if ([dev.hver isEqualToString:@"0"]) {
        [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:NSLocalizedString(@"This device is offline, please select other device", nil)];
        return;
    }
    
    [Util getAppDelegate].rootVC.pan.enabled = YES;
    
    NSString *logoStr = self.model.rfDataLogo;

    
//    [MMProgressHUD showWithStatus:NSLocalizedString(@"Updating", nil)];
    NSString *iconName = [iconArr objectAtIndex:btnTag - 1000];
    NSString *tempStr = nil;
    if (btnTag - 1000 == 8 && iconArr.count == 10) {
        tempStr = self.uuidStr;
        if ([tempStr hasPrefix:@".png"]) {
            tempStr = [tempStr stringByAppendingString:@".png"];
        }
    } else {
        tempStr = iconName;
    }
    
    RFDataModel *model = nil;
    if (self.typeNumber == 2) {
        model = [[RFDataModel alloc] init];
    } else if (self.typeNumber == 1) {
        model = self.model;
    }
    UInt8 byte[2];
    for (int i = 0; i < 2; i ++){
        byte[i] = arc4random() % 0xff;
    }
    NSData *data = [NSData dataWithBytes:byte length:2];
    
    
    for (RFDataModel *rfData in self.fmdbRFTableArray)
    {
        if ([[Util getRFAddressWith:rfData.address] isEqualToData:data]) {
            
            for (int i = 0; i < 2; i ++){
                byte[i] = arc4random() % 0xff;
            }
        }
    }
    model.rfDataLogo =  [iconArr objectAtIndex:btnTag - 1000];
    model.rfDataName = self.RFNameStr;
    model.rfDataMac = self.RFMacStrArr[rfMacTag];
    model.typeRF = [NSString stringWithFormat:@"%d", typeButIndex + 1];
    if (self.typeNumber == 2) {
        model.rfDataState = @"open";
        model.address = [NSString stringWithFormat:@"%02X%02X",byte[0],byte[1]];
        model.orderNumber = orderNumber + 1;

        [RFDataBase insertIntoDataBase:model];
        
    } else if (self.typeNumber == 1) {
        
        [RFDataBase updateFromDataBase:model];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self editRFDeviceSendToServer:model WithNewImageName:tempStr];
    });
    
    UIImage *endImage;
    if (btnTag - 1000 == 8 && iconArr.count == 10)
    {
        endImage = [[UIImage alloc] initWithContentsOfFile:[Util getFilePathWithImageName:iconName]];
    }
    else{
        endImage = [UIImage imageNamed:iconName];
    }

    if (![logoStr isEqualToString:self.model.rfDataLogo]) {
        
        if (iconArr.count == 10) {
            [iconArr removeObjectAtIndex:8];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendImageToServerWithimageName:tempStr WithImage:endImage];
        });
    }
    
    [self.navigationController popViewControllerAnimated:YES];

//    [self performSelector:@selector(dismissHUD) withObject:nil afterDelay:.2f];
}

- (void)deleteRFDeviceToServerWith:(RFDataModel *)model
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *tempString = [Util getPassWordWithmd5:[defaults objectForKey:KEY_PASSWORD]];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:AccessKey forKey:@"accessKey"];
    [dict setValue:[defaults objectForKey:KEY_USERMODEL] forKey:@"username"];
    [dict setValue:tempString forKey:@"password"];
    [dict setValue:model.rfDataMac forKey:@"macAddress"];
    [dict setValue:model.address forKey:@"addressCode"];
    
    NSString *timeSp = [NSString stringWithFormat:@"%f", (double)[[NSDate date] timeIntervalSince1970]*1000];
    
    NSArray *temp =   [timeSp componentsSeparatedByString:@"."];
    [dict setValue:[temp objectAtIndex:0] forKey:@"lastOperation"];
    [HTTPService POSTHttpToServerWith:DeleteRFURL WithParameters:dict   success:^(NSDictionary *dic) {
        
        NSString * success = [dic objectForKey:@"success"];
        
        if ([success boolValue] == true) {
            NSLog(@"成功");
            
        }
        if ([success boolValue] == false) {
            
//            [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:[dic objectForKey:@"msg"]];
            
        }
        
        
    } error:^(NSError *error) {
        //        [[Util getUtitObject] HUDHide];
        
//        [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:[NSString stringWithFormat:@"%@",error]];
        
    }];
}

#pragma mark - dismissHUD
- (void)dismissHUD
{
    [MMProgressHUD dismiss];
}

#pragma mark - edit/add RF device

- (void)editRFDeviceSendToServer:(RFDataModel *)rfModel_ WithNewImageName:(NSString *)imageName
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *tempString = [Util getPassWordWithmd5:[defaults objectForKey:KEY_PASSWORD]];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:AccessKey forKey:@"accessKey"];
    [dict setValue:[defaults objectForKey:KEY_USERMODEL] forKey:@"username"];
    [dict setValue:tempString forKey:@"password"];
    [dict setValue:rfModel_.rfDataMac forKey:@"macAddress"];
    [dict setValue:rfModel_.rfDataName forKey:@"deviceName"];
    [dict setValue:rfModel_.address forKey:@"addressCode"];
    [dict setValue:rfModel_.rfDataLogo forKey:@"imageName"];
    [dict setValue:rfModel_.typeRF forKey:@"type"];
    [dict setValue:[NSString stringWithFormat:@"%ld", (long)rfModel_.orderNumber] forKey:@"orderNumber"];
    
    NSString *timeSp = [NSString stringWithFormat:@"%f", (double)[[NSDate date] timeIntervalSince1970]*1000];
    
    NSArray *temp =   [timeSp componentsSeparatedByString:@"."];
    [dict setValue:[temp objectAtIndex:0] forKey:@"lastOperation"];
    
    [HTTPService POSTHttpToServerWith:EditRFURL WithParameters:dict success:^(NSDictionary *dic) {
        
        
        NSString * success = [dic objectForKey:@"success"];
        
        if ([success boolValue] == true) {
            NSLog(@"==== 成功添加RF设备至服务器 ===");
        }
        if ([success boolValue] == false) {
            
//            [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:[dic objectForKey:@"msg"]];
            
        }
        
        
    } error:^(NSError *error) {
        
//        [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:@"Link Timeout"];
    }];
}


- (void)sendImageToServerWithimageName:(NSString *)name WithImage:(UIImage *)image
{
    NSLog(@"name == %@ == image == %@", name, image);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tempString = [Util getPassWordWithmd5:[defaults objectForKey:KEY_PASSWORD]];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:AccessKey forKey:@"accessKey"];
    [dict setValue:[defaults objectForKey:KEY_USERMODEL] forKey:@"username"];
    [dict setValue:tempString forKey:@"password"];
    [dict setValue:name forKey:@"imageName"];
    
    
    [HTTPService PostHttpToServerImageAndDataWith:UploadURL WithParmeters:dict WithFilePath:nil imageName:name andImageFile:image success:^(NSDictionary *dic) {
        

        NSString * success = [dic objectForKey:@"success"];
        
        if ([success boolValue] == true) {
            NSLog(@"=== rf 图片上传成功 ===");
        }
        if ([success boolValue] == false) {
            NSLog(@"=== rf 图片上传失败 ===");
            
        }
        
    } error:^(NSError *error) {
        NSLog(@"=== rf 图片上传 超时 ===");
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
