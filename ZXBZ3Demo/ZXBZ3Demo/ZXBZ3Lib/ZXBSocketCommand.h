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

//请求更新效果文件      displayId:设备信息DisplayImageId
- (void)requestUploadDevice:(NSString *)displayId;

//格式化SD卡
- (void)formatSDCard;

//设置WiFi名称, 可为空
- (void)setWiFiName:(NSString *)name;

//设置WiFi密码, 设备版本号(Version)不小于200时可为空, 否则不可为空
- (void)setWiFiPassword:(NSString *)pwd;

/**
 绑定用户
 @param userStr 用户id
 @param device 设备的MAC地址(DeviceMacAdd)
 */
- (void)bingUser:(NSString *)userStr deviceMac:(NSString *)device;

/**
 连接到路由器
 @param ssid 路由器名称
 @param pws 路由器密码 (密码是8位以上)
 注意:①.绑定了路由器后设备不再发出WiFi热点,故不能对设备进行命令和文件操作.
     ②.先绑定用户再绑定到路由器,绑定成功后可在网络版中解除绑定,解绑后设备会重新发出WiFi热点.
     ③.若设备绑定了路由器没绑定用户,或者对应用户网络版中找不到设备,可将路由器关掉,等待1-3分钟设备就会发出WiFi热点.
 */
- (void)connectRouterSsid:(NSString *)ssid password:(NSString *)pws;



/** ===========以下命令只有设备版本号(Version)不小于200时可用, 否则无效============= */

//发送文件结束,发此命令设备会立即更新显示
- (void)sendFileEnd;

//重启命令
- (void)restartCommand;


//设备升级相关
//检查更新, 传入当前设备的版本号  (需要网络)
- (void)checkUpdataVersion:(NSString *)versionStr;

//从服务器下载更新文件到本地  (需要网络)
- (void)downloadUpdateFiletoLocal;

//从本地上传更新文件到设备
- (void)updataFileToDevice;


@end



@protocol ZXBCommandDelegate <NSObject>

@required
//接收设备信息
//StatusCode:1.正常, 2.设备停止运转, 3.设备无法连接
//Version:软件版本号
//HardVersion:硬件版本号
//DeviceMacAdd:设备的MAC地址
- (void)didReceivedInfo:(NSString *)info;

//断开连接
- (void)didDisconnected;


@optional
//更新显示      1->可以更新；2->不需要更新，已经有此效果文件；3->设备异常不能更新
- (void)didUploadResult:(int)code;

//格式化结果     1->格式化成功，2->设备异常，3->未能找到sd卡
- (void)didFormatResult:(int)code;

//设置名和称密码结果     0->名称, 2->密码
- (void)didSetWiFiSuccess:(int)type;

//绑定用户代理    1->绑定成功，3->绑定失败，设备异常
- (void)didBingUsersResult:(int)code;

//名称和密码已经发送至设备
- (void)didConnectRouter;


/** ===========以下代理方法只有设备版本号(Version)不小于200时才会回调============= */

//设备返回更新结束命令  1->更新成功；3->设备异常更新失败
- (void)didSendEndResult:(int)code;

//设备重启结果   //设备返回更新结束命令  1->更新成功；3->设备异常更新失败
- (void)didRestartResult:(int)code;


//设备升级相关
//检查更新结果     1->检测到本地有新版本，2->检测到服务器有新版本，3->未检测到更新文件，4->不需要升级，5->请连接到外网后获取最新版本
// code为1和2时versionStr有值, 值为最新版本号
//本地和服务器,会优先使用版本号高的
//若版本号相同,优先使用本地的
- (void)checkUpdataResult:(int)code version:(NSString *)versionStr;

//完成进度 (包括从服务器下载 和 上传到设备的进度)
- (void)didUpdataProgress:(float)progress;

//下载到本地完成
- (void)didCompleteDownloadUpdataFile;

//上传更新文件到设备结果  1->上传成功，等待设备重启升级\n升级过程，请勿断电，2->升级文件不存在或校验失败，3->设备异常
- (void)didUploadToDeviceResult:(int)code;

//请求失败 (包括从服务器下载 和 上传到设备的失败)
- (void)didFailRequestError:(NSError *)error;




@end








