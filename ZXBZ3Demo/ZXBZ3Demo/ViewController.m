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

@interface ViewController () <ZXBCommandDelegate>

@property (nonatomic, strong) ZXBSocketCommand *socketCommand;
@property (nonatomic, copy) NSDictionary *infoDic;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.socketCommand.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"Demo";
    
    self.view.backgroundColor = [UIColor cyanColor];
    
    [self creatButton];
    
    [self.socketCommand getDeviceMessage];
}

- (ZXBSocketCommand *)socketCommand
{
    if (!_socketCommand){
        _socketCommand = [[ZXBSocketCommand defaultSocket] initWithSocket];
    }
    return _socketCommand;
}

- (void)creatButton
{
    NSArray *titleArr = @[@"获取设备信息", @"文件操作", @"格式化SD卡", @"连接路由器", @"修改WiFi名称", @"修改WiFi密码", @"检查更新", @"断开连接"];
    for (int i=0; i<titleArr.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((KScreenWidth-150)*0.5, 20+(40+20)*i, 150, 40)];
        btn.backgroundColor = [UIColor orangeColor];
        [btn setTitle:titleArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        btn.tag = 120+i;
        [btn addTarget:self action:@selector(functionBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

#pragma mark - Action
- (void)functionBtnAction:(UIButton *)btn
{
    switch (btn.tag-120) {
        case 0:{        //获取设备信息
            [self.socketCommand getDeviceMessage];
        }
            break;
        case 1:{        //文件操作
            if (self.infoDic){
                FileController *vc = [[FileController alloc] init];
                vc.infoDic = self.infoDic;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                NSLog(@">>>>设备信息为空");
            }
        }
            break;
        case 2:{        //格式化SD卡
            WeakSelf(self);
            UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"警告" message:@"确定格式化SD卡？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
                [weakself.socketCommand formatSDCard];
            }];
            [alertCtr addAction:cancel];
            [alertCtr addAction:okBtn];
            [self presentViewController:alertCtr animated:YES completion:nil];
        }
            break;
        case 3:{        //连接路由器
            if (self.infoDic){
                //先绑定用户
                WeakSelf(self);
                UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:@"请确保输入的WiFi名称和密码正确，否则设备不能连接到外网" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    
#warning 用户id需要网络版获取, 本SDK只提供单机版
                    //先绑定用户, 绑定结果后 didBingUsersResult
                    [weakself.socketCommand bingUser:@"841" deviceMac:self.infoDic[@"DeviceMacAdd"]];
                }];
                [alertCtr addAction:cancel];
                [alertCtr addAction:okBtn];
                [self presentViewController:alertCtr animated:YES completion:nil];
            }else{
                NSLog(@">>>>请先获取设备信息");
            }
        }
            break;
        case 4:{        //修改WiFi名称
            [self.socketCommand setWiFiName:@"ZXB_Demo"];
        }
            break;
        case 5:{        //修改WiFi密码
            [self.socketCommand setWiFiPassword:@"12345678"];
        }
            break;
        case 6:{        //检查更新
            //设备版本号(Version)不小于200时可用, 否则不可更新
            if ([self.infoDic[@"Version"] intValue] >= 200){
                [self.socketCommand checkUpdataVersion:self.infoDic[@"Version"]];
            }else{
                NSLog(@">>>>>>不需要升级");
            }
        }
            break;
        case 7:{        //断开连接
            [self.socketCommand deinit];
            self.infoDic = nil;
        }
            break;
        default:
            break;
    }
}


#pragma mark - ZXBCommandDelegate
- (void)didReceivedInfo:(NSString *)info{
    self.infoDic = [Tools getURLParameters:info];
    NSLog(@">>>>%@", self.infoDic);
}

- (void)didDisconnected{
    NSLog(@">>>>设备断开连接");
}

//格式化结果     1->格式化成功，2->设备异常，3->未能找到sd卡
- (void)didFormatResult:(int)code{
    if (code == 1){
        NSLog(@">>>>>格式化成功");
    }else{
        NSLog(@">>>>>格式化失败");
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
        NSLog(@">>>>>绑定用户失败");
    }
}
//绑定路由器成功
- (void)didConnectRouter{
    NSLog(@">>>>>名称和密码已经发送至设备");
}
//设置名和称密码结果     0->名称, 2->密码
- (void)didSetWiFiSuccess:(int)type{
    NSString *titleStr;
    if (type == 0){
        NSLog(@">>>>>设置WiFi名称成功，重启设备后生效");
        titleStr = @"设置名称成功";
    }else{
        NSLog(@">>>>>设置WiFi密码成功，重启设备后生效");
        titleStr = @"设置密码成功";
    }
    
    //重启命令, 设备版本号(Version)不小于200时可用, 否则无效
    WeakSelf(self);
    if ([self.infoDic[@"Version"] intValue] >= 200){
        UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:titleStr message:@"重启设备后生效" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"重启" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            //发送重启命令
            [weakself.socketCommand restartCommand];
        }];
        [alertCtr addAction:cancel];
        [alertCtr addAction:okBtn];
        [self presentViewController:alertCtr animated:YES completion:nil];
    }else{
        UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:titleStr message:@"重启设备后生效" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertCtr addAction:cancel];
        [self presentViewController:alertCtr animated:YES completion:nil];
    }
    
}



#pragma mark - 设备升级相关
//检查更新结果     1->检测到本地有新版本，2->检测到服务器有新版本，3->未检测到更新文件，4->不需要升级，5->请连接到外网后获取最新版本
// code为1和2时versionStr有值, 值为最新版本号
- (void)checkUpdataResult:(int)code version:(NSString *)versionStr
{
    WeakSelf(self);
    if (code == 1){
        //本地有更新文件
        UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"版本%@", versionStr] message:@"是否上传到设备?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            //从本地上传更新文件到设备
            [weakself.socketCommand updataFileToDevice];
            NSLog(@">>>上传更新文件到设备");
        }];
        [alertCtr addAction:cancel];
        [alertCtr addAction:okBtn];
        [self presentViewController:alertCtr animated:YES completion:nil];
    }else if (code == 2){
        //需要去服务器下载更新文件
        UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"检测到版本%@", versionStr] message:@"是否下载?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            //从服务器下载更新文件到本地  (需要网络)
            [weakself.socketCommand downloadUpdateFiletoLocal];
            NSLog(@">>>下载更新文件");
        }];
        [alertCtr addAction:cancel];
        [alertCtr addAction:okBtn];
        [self presentViewController:alertCtr animated:YES completion:nil];
    }else{
        NSArray *msgArr = @[@"未检测到更新文件", @"不需要升级", @"请连接到外网后获取最新版本"];
        NSLog(@">>>>>>%@", (code<=5)?msgArr[code-3]:@"升级失败");
    }
}

//完成进度 (包括从服务器下载 和 上传到设备的进度)
- (void)didUpdataProgress:(float)progress
{
    NSLog(@"===>%f", progress);
}

//下载到本地完成
- (void)didCompleteDownloadUpdataFile
{
    WeakSelf(self);
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"下载完成" message:@"是否上传到设备?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        //从本地上传更新文件到设备
        [weakself.socketCommand updataFileToDevice];
        NSLog(@">>>上传更新文件到设备");
    }];
    [alertCtr addAction:cancel];
    [alertCtr addAction:okBtn];
    [self presentViewController:alertCtr animated:YES completion:nil];
}

//上传更新文件到设备结果  1->上传成功，等待设备重启升级\n升级过程，请勿断电，2->升级文件不存在或校验失败，3->设备异常
- (void)didUploadToDeviceResult:(int)code
{
    switch (code) {
        case 1: {
            UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"上传成功，等待设备重启升级\n升级过程，请勿断电" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertCtr addAction:cancel];
            [self presentViewController:alertCtr animated:YES completion:nil];
        } break;
        case 2: NSLog(@">>>>升级文件不存在或校验失败"); break;
        default: NSLog(@">>>>设备异常"); break;
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
