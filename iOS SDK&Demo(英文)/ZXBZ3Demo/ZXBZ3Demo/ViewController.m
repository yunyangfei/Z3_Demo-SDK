//
//  ViewController.m
//  ZXBZ3Demo
//
//  Created by 刘清 on 2018/12/15.
//  Copyright © 2018 WIIKK. All rights reserved.
//

#import "ViewController.h"
#import "ZXBSocketCommand.h"
#import "FileController.h"
#import "Tools.h"
#import "WSProgressHUD.h"

@interface ViewController () <ZXBCommandDelegate>

@property (nonatomic, strong) WSProgressHUD *hud;
@property (nonatomic, strong) ZXBSocketCommand *socketCommand;
@property (nonatomic, copy) NSDictionary *infoDic;
@property (nonatomic, assign) NSInteger luminance;//亮度值
@property (nonatomic, assign) NSInteger angle;//角度值
@property (weak, nonatomic) IBOutlet UISwitch *powerSwitch;
@property (weak, nonatomic) IBOutlet UILabel *powerLabel;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.socketCommand.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"Wiikk Demo";
    
    self.view.backgroundColor = [UIColor cyanColor];
    
    [self confirmView];
    
    //Get device information
    [self showHudLoadingString:@"Loading"];
    [self.socketCommand getDeviceMessage];
}

- (ZXBSocketCommand *)socketCommand
{
    if (!_socketCommand){
        _socketCommand = [[ZXBSocketCommand defaultSocket] initWithSocket];
    }
    return _socketCommand;
}

- (void)confirmView
{
    self.powerLabel.text = @"Turn on/off:";
    NSArray *titleArr = @[@"Get device information", @"File Operations", @"Format SD Card", @"Connect router", @"Modify WiFi Name", @"Modify WiFi Password", @"Check for updates", @"Disconnect", @"Reduced Brightness", @"Get Brightness", @"Save Brightness", @"Increased Brightness", @"Reduced Angle", @"Get Angle", @"Save Angle", @"Increased Angle"];
    for (int i=0; i<titleArr.count; i++) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:120+i];
        [btn setTitle:titleArr[i] forState:UIControlStateNormal];
        btn.titleLabel.numberOfLines = 2;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    //Set the initial value to -1, Tip to get brightness or angle first
    self.luminance = -1;//Brightness Value
    self.angle = -1;//Angel data Value
}

#pragma mark - Action
- (IBAction)functionBtnAction:(UIButton *)btn
{
    switch (btn.tag-120) {
        case 0:{        //Get device information
            [self showHudLoadingString:@"Loading"];
            [self.socketCommand getDeviceMessage];
        }   break;
        case 1:{        //File Operations
            if (self.infoDic){
                FileController *vc = [[FileController alloc] init];
                vc.infoDic = self.infoDic;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                NSLog(@">>>>Device information is empty");
            }
        }   break;
        case 2:{        //Format SD Card
            WeakSelf(self);
            UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Are you sure you want to format the SD card?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
                [weakself showHudLoadingString:@"Loading"];
                [weakself.socketCommand formatSDCard];
            }];
            [alertCtr addAction:cancel];
            [alertCtr addAction:okBtn];
            [self presentViewController:alertCtr animated:YES completion:nil];
        }   break;
        case 3:{        //Connect router
            if (self.infoDic){
                //First bind user
                WeakSelf(self);
                UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:@"Make sure you enter the correct WiFi name and password" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    
#warning User ID needs to be obtained online version, this SDK only provides
                    //Binding user first, after binding result:(didBingUsersResult)
                    [weakself showHudLoadingString:@"Loading"];
                    [weakself.socketCommand bingUser:@"841" deviceName:@"Test Device" domain:@"www.wiikk.cn:8088"];
                }];
                [alertCtr addAction:cancel];
                [alertCtr addAction:okBtn];
                [self presentViewController:alertCtr animated:YES completion:nil];
            }else{
                [WSProgressHUD showWarningWithStatus:@"Please get the device information first"];
            }
        }   break;
        case 4:{        //Modify WiFi Name
            [self showHudLoadingString:@"Loading"];
            [self.socketCommand setWiFiName:@"ZXB_Demo"];
        }   break;
        case 5:{        //Modify WiFi Password
            [self showHudLoadingString:@"Loading"];
            [self.socketCommand setWiFiPassword:@"12345678"];
        }   break;
        case 6:{        //Check for updates
            //Note: This upgrade package (fFirmware3221.bin) can only upgrade Z3H devices
            NSInteger hardVer = [self.infoDic[@"HardVersion"] integerValue];
            if (hardVer>=480 && hardVer<=499){
                NSString *path = [[NSBundle mainBundle] pathForResource:@"Firmware3221" ofType:@"bin"];
                [self showHudLoadingString:@"Loading"];
                [self.socketCommand updataDeviceWithBinPath:path];
            }else{
                [WSProgressHUD showWarningWithStatus:@"Upgrade package is Z3H"];
            }
        }   break;
        case 7:{        //Disconnect
            [self.socketCommand deinit];
            self.infoDic = nil;
        }   break;
        case 8:{        //Reduced Brightness
            if (self.luminance == -1){
                [WSProgressHUD showWarningWithStatus:@"Please get brightness first"];
            }else{
                if (self.luminance > 0){
                    [self setDeviceLuminance:[NSString stringWithFormat:@"%zi", (long)(self.luminance-1)]];
                }
            }
        }   break;
        case 9:{        //Get Brightness
            [self setDeviceLuminance:nil];
        }   break;
        case 10:{        //Save Brightness
            [self setDeviceLuminance:@"save"];
        }    break;
        case 11:{        //Increased Brightness
            if (self.luminance == -1){
                [WSProgressHUD showWarningWithStatus:@"Please get brightness first"];
            }else{
                if (self.luminance < 100){
                    [self setDeviceLuminance:[NSString stringWithFormat:@"%zi", (long)(self.luminance+1)]];
                }
            }
        }   break;
        case 12:{        //Reduced Angle
            if (self.angle == -1){
                [WSProgressHUD showWarningWithStatus:@"Please get Angle first"];
            }else{
                if (self.angle > 0){
                    [self setDeviceAngle:[NSString stringWithFormat:@"%zi", (long)(self.angle-1)]];
                }
            }
        }   break;
        case 13:{        //Get Angle
            [self setDeviceAngle:nil];
        }   break;
        case 14:{        //Save Angle
            [self setDeviceAngle:@"save"];
        }   break;
        case 15:{        //Increased Angle
            if (self.angle == -1){
                [WSProgressHUD showWarningWithStatus:@"Please get Angle first"];
            }else{
                if (self.angle < 360){
                    [self setDeviceAngle:[NSString stringWithFormat:@"%zi", (long)(self.angle+1)]];
                }
            }
        }   break;
        default:
            break;
    }
}
//Turn on/off
- (IBAction)powerSwitchChange:(UISwitch *)sender
{
    [self showHudLoadingString:@"Loading"];
    [self.socketCommand devicePower:[NSString stringWithFormat:@"%d", sender.on]];
}

//Set Brightness
- (void)setDeviceLuminance:(NSString *)luminance
{
    [self showHudLoadingString:@"Loading"];
    [self.socketCommand luminanceController:luminance];
}
//Set Angle
- (void)setDeviceAngle:(NSString *)angle
{
    [self showHudLoadingString:@"Loading"];
    [self.socketCommand angleController:angle];
}


#pragma mark - ZXBCommandDelegate
- (void)didReceivedInfo:(NSString *)info{
    [self hideHud];
    self.infoDic = [Tools getURLParameters:info];
    self.powerSwitch.on = [self.infoDic[@"Power"] boolValue];
    NSLog(@">>>>%@", self.infoDic);
}

- (void)didDisconnected{
    [self hideHud];
    [WSProgressHUD showErrorWithStatus:@"Device Disconnected"];
}

//Formatting results  1-> Success,  2-> Device exception, 3-> Sd card not founded
- (void)didFormatResult:(int)code{
    [self hideHud];
    if (code == 1){
        [WSProgressHUD showSuccessWithStatus:@"Formatting successed"];
    }else{
        [WSProgressHUD showErrorWithStatus:@"Formatting failed"];
    }
}
//Binding User Agent  1-> Success, 3-> Failed, Device exception
- (void)didBingUsersResult:(int)code{
    if (code == 1){
        //After the user is successfully bound, send the connection router command
        NSLog(@">>>>>Binding user successful");
#warning Router ID and Password must be filled in correctly
        [self.socketCommand connectRouterSsid:@"abc" password:@"12345678"];
    }else{
        [self hideHud];
        [WSProgressHUD showErrorWithStatus:@"Failed to bind user"];
    }
}
//Binding router successful
- (void)didConnectRouter{
    [self hideHud];
    [WSProgressHUD showSuccessWithStatus:@"Name and password sent to device"];
}
//Set Name Result
- (void)didSetWiFiNameSuccess{
    [self hideHud];
    WeakSelf(self);
    if ([self.infoDic[@"Version"] intValue] >= 200){
        UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"Setting name successful" message:@"Effective after rebooting the device" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"Restart" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            //Send a restart command
            [weakself showHudLoadingString:@"Loading"];
            [weakself.socketCommand restartCommand];
        }];
        [alertCtr addAction:cancel];
        [alertCtr addAction:okBtn];
        [self presentViewController:alertCtr animated:YES completion:nil];
    }else{
        UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"Setting name successful" message:@"Effective after rebooting the device" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertCtr addAction:cancel];
        [self presentViewController:alertCtr animated:YES completion:nil];
    }
}
//Set password result
- (void)didSetWiFiPasswordSuccess{
    [self hideHud];
    WeakSelf(self);
    if ([self.infoDic[@"Version"] intValue] >= 200){
        UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"Password setup successful" message:@"Effective after rebooting the device" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"Restart" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            //发送重启命令
            [weakself showHudLoadingString:@"Loading"];
            [weakself.socketCommand restartCommand];
        }];
        [alertCtr addAction:cancel];
        [alertCtr addAction:okBtn];
        [self presentViewController:alertCtr animated:YES completion:nil];
    }else{
        UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"Password setup successful" message:@"Effective after rebooting the device" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertCtr addAction:cancel];
        [self presentViewController:alertCtr animated:YES completion:nil];
    }
}
//Device restart results  1-> Success, 3->Failed
- (void)didRestartResult:(int)code{
    [self hideHud];
    if (code == 1){
        [WSProgressHUD showSuccessWithStatus:@"Restart successful, please reconnect device"];
    }else{
        NSLog(@">>>>Restart failed");
    }
}
//Upload complete progress
- (void)didUpdataProgress:(float)progress{
    NSLog(@"Upload progress===>%f", progress);
    [self showHudLoadingString:[NSString stringWithFormat:@"Uploading %d%%", (int)(progress*100)]];
}

//Upload update file to device result
//1-> Upload successfully, wait for device restart upgrade. Do not cut off power.
//2-> Upgrade file does not exist or failed to check
//3-> Device exception
- (void)didUploadToDeviceResult:(int)code{
    [self hideHud];
    if (code == 1){
        [WSProgressHUD showSuccessWithStatus:@"Upload successfully, wait for device restart upgrade. Do not cut off power"];
    }
}

//Back to open and shut down result
- (void)didPowerResult:(BOOL)power{
    [self hideHud];
    self.powerSwitch.on = power;
}

//Return Brightness
//If the return value is always 100, the device hardware is not supported
- (void)didLuminanceResult:(NSString *)luminance{
    [self hideHud];
    if (luminance.intValue>=0 && luminance.intValue<=100){
        self.luminance = luminance.integerValue;
        [WSProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Brightness:%@", luminance]];
    }
}

//Return Angle
//If the returned value range is not 0 ~ 360, the device hardware is not supported
- (void)didAngleResult:(NSString *)angle{
    [self hideHud];
    if (angle.intValue>=0 && angle.intValue<=360){
        self.angle = angle.integerValue;
        [WSProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Angle:%@", angle]];
    }else{
        [WSProgressHUD showWarningWithStatus:@"This hardware is not supported"];
    }
}


- (WSProgressHUD *)hud{
    if (!_hud){
        _hud = [[WSProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    return _hud;
}
- (void)showHudLoadingString:(NSString *)str
{
    [self.hud setProgressHUDIndicatorStyle:WSProgressHUDIndicatorSmallLight];
    [self.hud showWithString:str maskType:WSProgressHUDMaskTypeClear];
}
- (void)hideHud
{
    [self.hud dismiss];
    [self.hud removeFromSuperview];
    self.hud = nil;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
