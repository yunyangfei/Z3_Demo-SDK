//
//  ZXBSocketCommand.h
//  ZXBZ3
//
//  Created by 刘清 on 2018/12/15.
//  Copyright © 2018 WIIKK. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZXBCommandDelegate;
@interface ZXBSocketCommand : NSObject

@property (strong) id<ZXBCommandDelegate> delegate;

//单例
+ (instancetype)defaultSocket;

//初始化(连接设备)
- (instancetype)initWithSocket;

//断开连接
- (void)deinit;


//获取设备信息
- (void)getDeviceMessage;

//格式化SD卡
- (void)formatSDCard;

//设置WiFi名称, 可为空
- (void)setWiFiName:(NSString *)name;

//设置WiFi密码, 老设备(Z3)可为空, 新设备(Z3s)不可为空
- (void)setWiFiPassword:(NSString *)pwd;

/**
 绑定用户
 @param userStr 用户id
 @param nameStr 设置设备名字
 @param domainStr 绑定域名 (www.wiikk.cn:8088)
 */
- (void)bingUser:(NSString *)userStr deviceName:(NSString *)nameStr domain:(NSString *)domainStr;

/**
 连接到路由器
 @param ssid 路由器名称
 @param pws 路由器密码 (密码是8位以上)
 */
- (void)connectRouterSsid:(NSString *)ssid password:(NSString *)pws;


//请求更新效果文件(发送文件前先发此命令,设备会关掉蓝牙. 否则蓝牙未关闭会影响传输速度)
- (void)requestUploadDevice;

//发送文件结束(更新播放列表),发此命令设备会更新播放列表,同时会打开蓝牙
- (void)sendFileEnd;

//重启命令(修改wifi名称和密码后,重启生效)   =======  仅Z3s和Z3_480设备可用
- (void)restartCommand;


//开始更新设备,path为升级包的路径      =======  仅Z3s和Z3_480设备可用
/**  注意:1.调用后会往设备发送升级包, 可通过代理方法didUpdataProgress获取上传进度
         2.上传成功后会自动重启设备, 请提示用户:上传成功,等待设备重启升级,升级过程,请勿断电
         3.上传完成的代理方法:didUploadToDeviceResult
 */
- (void)updataDeviceWithBinPath:(NSString *)path;

//获取当前正在播放的文件       =======  仅Z3s和Z3_480设备可用
/**  1.fileName为nil时,为获取当前播放的文件,通过代理方法返回.
     2.fileName不为nil时,设备会立即播放该文件.(fileName为文件名)
     3.fileName必须是设备内存在的文件,否则设备会显示"video"
 */
- (void)getCurrentPlayingFileName:(NSString *)nameStr;

//开关机, Power为nil时为获取开关机状态, @"1"表示开机, @"0"表示关机       =======  仅Z3s和Z3_480设备可用
//设备开关机仅Z3_480可用, Z3s不管发送什么,总是返回开机
- (void)devicePower:(NSString *)power;

//亮度调节  范围为0~100        =======  仅Z3s和Z3_480设备可用
//luminance为nil时为获取亮度值
//luminance为@"save"时为保存当前亮度
//注意:调节亮度后如果未进行保存,断电重启后将恢复之前亮度
- (void)luminanceController:(NSString *)luminance;

//角度调节  范围为0~360        =======  仅Z3s和Z3_480设备可用
//angle为nil时为获取亮度值
//angle为@"save"时为保存当前角度
//注意:1.调节角度后如果未进行保存,断电重启后将恢复之前角度
//    2.由于Z3s和Z3_480设备硬件不同可能需要进行换算
//    3.Z3s设备0度时是正的, Z3_480设备90度是正的
- (void)angleController:(NSString *)angle;


@end



@protocol ZXBCommandDelegate <NSObject>

@required
//接收设备信息
//StatusCode:1.正常, 2.设备停止运转, 3.设备无法连接
//Version:软件版本号
//HardVersion:硬件版本号
//DeviceMacAdd:设备的MAC地址
//Power:开关机状态
//DisplayImageId:正在播放的文件名
- (void)didReceivedInfo:(NSString *)info;

//断开连接
- (void)didDisconnected;


@optional

//格式化结果     1->格式化成功，2->设备异常，3->未能找到sd卡
- (void)didFormatResult:(int)code;

//设置名称结果
- (void)didSetWiFiNameSuccess;

//设置密码结果
- (void)didSetWiFiPasswordSuccess;

//绑定用户代理    1->绑定成功，3->绑定失败，设备异常
- (void)didBingUsersResult:(int)code;

//名称和密码已经发送至设备
- (void)didConnectRouter;

//更新显示      1->可以更新；2->不需要更新，已经有此效果文件；3->设备异常不能更新
- (void)didUploadResult:(int)code;

//设备返回更新结束命令  1->更新成功；3->设备异常更新失败
- (void)didSendEndResult:(int)code;

//设备重启结果  1->重启成功；3->重启失败
- (void)didRestartResult:(int)code;

//上传完成进度
- (void)didUpdataProgress:(float)progress;

//上传更新文件到设备结果  1->上传成功，等待设备重启升级\n升级过程，请勿断电，2->升级文件不存在或校验失败，3->设备异常
- (void)didUploadToDeviceResult:(int)code;

//返回当前正在播放的文件
- (void)didCurrentPlayFileName:(NSString *)nameStr;

//返回开关机结果
- (void)didPowerResult:(BOOL)power;

//返回亮度
//若返回值一直为100, 则表示此设备硬件不支持
- (void)didLuminanceResult:(NSString *)luminance;

//返回角度
//若返回的值范围不是0~360, 则表示此设备硬件不支持
- (void)didAngleResult:(NSString *)angle;



@end








