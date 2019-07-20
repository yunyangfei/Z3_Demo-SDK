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
    self.navigationItem.title = @"众兴邦Demo";
    
    self.view.backgroundColor = [UIColor cyanColor];
    
    [self confirmView];
    
    //获取设备信息
    [self showHudLoadingString:@"加载中"];
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
    self.powerLabel.text = @"开关机:";
    NSArray *titleArr = @[@"获取设备信息", @"文件操作", @"格式化SD卡", @"连接路由器", @"修改WiFi名称", @"修改WiFi密码", @"检查更新", @"断开连接", @"亮度减", @"获取亮度", @"保存亮度", @"亮度加", @"角度减", @"获取角度", @"保存角度", @"角度加"];
    for (int i=0; i<titleArr.count; i++) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:120+i];
        [btn setTitle:titleArr[i] forState:UIControlStateNormal];
    }
    
    //设置初始值为-1, 提示先获取亮度或角度
    self.luminance = -1;//亮度值
    self.angle = -1;//角度值
}

#pragma mark - Action
- (IBAction)functionBtnAction:(UIButton *)btn
{
    switch (btn.tag-120) {
        case 0:{        //获取设备信息
            [self showHudLoadingString:@"加载中"];
            [self.socketCommand getDeviceMessage];
        }   break;
        case 1:{        //文件操作
            if (self.infoDic){
                FileController *vc = [[FileController alloc] init];
                vc.infoDic = self.infoDic;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                NSLog(@">>>>设备信息为空");
            }
        }   break;
        case 2:{        //格式化SD卡
            WeakSelf(self);
            UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"警告" message:@"确定格式化SD卡？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
                [weakself showHudLoadingString:@"加载中"];
                [weakself.socketCommand formatSDCard];
            }];
            [alertCtr addAction:cancel];
            [alertCtr addAction:okBtn];
            [self presentViewController:alertCtr animated:YES completion:nil];
        }   break;
        case 3:{        //连接路由器
            if (self.infoDic){
                //先绑定用户
                WeakSelf(self);
                UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:@"请确保输入的WiFi名称和密码正确" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    
#warning 用户id需要网络版获取, 本SDK只提供单机版
                    //先绑定用户, 绑定结果后 didBingUsersResult
                    [weakself showHudLoadingString:@"加载中"];
                    [weakself.socketCommand bingUser:@"841" deviceMac:self.infoDic[@"DeviceMacAdd"]];
                }];
                [alertCtr addAction:cancel];
                [alertCtr addAction:okBtn];
                [self presentViewController:alertCtr animated:YES completion:nil];
            }else{
                [WSProgressHUD showWarningWithStatus:@"请先获取设备信息"];
            }
        }   break;
        case 4:{        //修改WiFi名称
            [self showHudLoadingString:@"加载中"];
            [self.socketCommand setWiFiName:@"ZXB_Demo"];
        }   break;
        case 5:{        //修改WiFi密码
            [self showHudLoadingString:@"加载中"];
            [self.socketCommand setWiFiPassword:@"12345678"];
        }   break;
        case 6:{        //检查更新
            //Z3s设备(版本号(Version)不小于200时可用), 否则不可更新
            if ([self.infoDic[@"Version"] intValue] >= 200){
                NSString *path = [[NSBundle mainBundle] pathForResource:@"Firmware3214" ofType:@"bin"];
                [self showHudLoadingString:@"加载中"];
                [self.socketCommand updataDeviceWithBinPath:path];
            }else{
                [WSProgressHUD showWarningWithStatus:@"不需要升级"];
            }
        }   break;
        case 7:{        //断开连接
            [self.socketCommand deinit];
            self.infoDic = nil;
        }   break;
        case 8:{        //亮度减
            if (self.luminance == -1){
                [WSProgressHUD showWarningWithStatus:@"请先获取亮度"];
            }else{
                if (self.luminance > 0){
                    [self setDeviceLuminance:[NSString stringWithFormat:@"%zi", (long)(self.luminance-1)]];
                }
            }
        }   break;
        case 9:{        //获取亮度
            [self setDeviceLuminance:nil];
        }   break;
        case 10:{        //保存亮度
            [self setDeviceLuminance:@"save"];
        }    break;
        case 11:{        //亮度加
            if (self.luminance == -1){
                [WSProgressHUD showWarningWithStatus:@"请先获取亮度"];
            }else{
                if (self.luminance < 360){
                    [self setDeviceLuminance:[NSString stringWithFormat:@"%zi", (long)(self.luminance+1)]];
                }
            }
        }   break;
        case 12:{        //角度减
            if (self.angle == -1){
                [WSProgressHUD showWarningWithStatus:@"请先获取角度"];
            }else{
                if (self.angle > 0){
                    [self setDeviceAngle:[NSString stringWithFormat:@"%zi", (long)(self.angle-1)]];
                }
            }
        }   break;
        case 13:{        //获取角度
            [self setDeviceAngle:nil];
        }   break;
        case 14:{        //保存角度
            [self setDeviceAngle:@"save"];
        }   break;
        case 15:{        //角度加
            if (self.angle == -1){
                [WSProgressHUD showWarningWithStatus:@"请先获取角度"];
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
//开关机
- (IBAction)powerSwitchChange:(UISwitch *)sender
{
    [self showHudLoadingString:@"加载中"];
    [self.socketCommand devicePower:[NSString stringWithFormat:@"%d", sender.on]];
}

//设置亮度
- (void)setDeviceLuminance:(NSString *)luminance
{
    [self showHudLoadingString:@"加载中"];
    [self.socketCommand luminanceController:luminance];
}
//设置角度
- (void)setDeviceAngle:(NSString *)angle
{
    [self showHudLoadingString:@"加载中"];
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
    [WSProgressHUD showErrorWithStatus:@"设备断开连接"];
}

//格式化结果     1->格式化成功，2->设备异常，3->未能找到sd卡
- (void)didFormatResult:(int)code{
    [self hideHud];
    if (code == 1){
        [WSProgressHUD showSuccessWithStatus:@"格式化成功"];
    }else{
        [WSProgressHUD showErrorWithStatus:@"格式化失败"];
    }
}
//绑定用户代理    1->绑定成功，3->绑定失败，设备异常
- (void)didBingUsersResult:(int)code{
    if (code == 1){
        //绑定用户成功后, 再发送连接路由器命令
        NSLog(@">>>>>绑定用户成功");
#warning 路由器名字和密码需要填写正确
        [self.socketCommand connectRouterSsid:@"abc" password:@"12345678"];
    }else{
        [self hideHud];
        [WSProgressHUD showErrorWithStatus:@"绑定用户失败"];
    }
}
//绑定路由器成功
- (void)didConnectRouter{
    [self hideHud];
    [WSProgressHUD showSuccessWithStatus:@"名称和密码已经发送至设备"];
}
//设置名称结果
- (void)didSetWiFiNameSuccess{
    [self hideHud];
    WeakSelf(self);
    if ([self.infoDic[@"Version"] intValue] >= 200){
        UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"设置名称成功" message:@"重启设备后生效" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"重启" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            //发送重启命令
            [weakself showHudLoadingString:@"加载中"];
            [weakself.socketCommand restartCommand];
        }];
        [alertCtr addAction:cancel];
        [alertCtr addAction:okBtn];
        [self presentViewController:alertCtr animated:YES completion:nil];
    }else{
        UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"设置名称成功" message:@"重启设备后生效" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertCtr addAction:cancel];
        [self presentViewController:alertCtr animated:YES completion:nil];
    }
}
//设置密码结果
- (void)didSetWiFiPasswordSuccess{
    [self hideHud];
    WeakSelf(self);
    if ([self.infoDic[@"Version"] intValue] >= 200){
        UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"设置密码成功" message:@"重启设备后生效" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"重启" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            //发送重启命令
            [weakself showHudLoadingString:@"加载中"];
            [weakself.socketCommand restartCommand];
        }];
        [alertCtr addAction:cancel];
        [alertCtr addAction:okBtn];
        [self presentViewController:alertCtr animated:YES completion:nil];
    }else{
        UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"设置密码成功" message:@"重启设备后生效" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertCtr addAction:cancel];
        [self presentViewController:alertCtr animated:YES completion:nil];
    }
}
//设备重启结果  1->重启成功；3->重启失败
- (void)didRestartResult:(int)code{
    [self hideHud];
    if (code == 1){
        [WSProgressHUD showSuccessWithStatus:@"重启成功,请重新连接设备"];
    }else{
        NSLog(@">>>>重启失败");
    }
}
//上传完成进度
- (void)didUpdataProgress:(float)progress{
    NSLog(@"上传进度===>%f", progress);
    [self showHudLoadingString:[NSString stringWithFormat:@"上传中%d%%", (int)(progress*100)]];
}

//上传更新文件到设备结果  1->上传成功，等待设备重启升级\n升级过程，请勿断电，2->升级文件不存在或校验失败，3->设备异常
- (void)didUploadToDeviceResult:(int)code{
    [self hideHud];
    if (code == 1){
        [WSProgressHUD showSuccessWithStatus:@"上传成功，等待设备重启升级\n升级过程，请勿断电"];
    }
}

//返回开关机结果
- (void)didPowerResult:(BOOL)power{
    [self hideHud];
    self.powerSwitch.on = power;
}

//返回亮度
//若返回值一直为100, 则表示此设备硬件不支持
- (void)didLuminanceResult:(NSString *)luminance{
    [self hideHud];
    if (luminance.intValue>=0 && luminance.intValue<=100){
        self.luminance = luminance.integerValue;
        [WSProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"亮度:%@", luminance]];
    }
}

//返回角度
//若返回的值范围不是0~360, 则表示此设备硬件不支持
- (void)didAngleResult:(NSString *)angle{
    [self hideHud];
    if (angle.intValue>=0 && angle.intValue<=360){
        self.angle = angle.integerValue;
        [WSProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"角度:%@", angle]];
    }else{
        [WSProgressHUD showWarningWithStatus:@"此硬件不支持"];
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
