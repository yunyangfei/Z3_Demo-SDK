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

//Singleton
+ (instancetype)defaultSocket;

//Initialization(connecting device)
- (instancetype)initWithSocket;

//Disconnected
- (void)deinit;


//Get device information
- (void)getDeviceMessage;

//Formatting SD Card
- (void)formatSDCard;

//Set WiFi name , can be empty
- (void)setWiFiName:(NSString *)name;

//et WiFi password, old device(Z3) can be empty, new device(Z3s) can not be empty
- (void)setWiFiPassword:(NSString *)pwd;

/**
 Binding users
 @param userStr  User ID
 @param nameStr  Device name
 @param domainStr  Bind domain
 */
- (void)bingUser:(NSString *)userStr deviceName:(NSString *)nameStr domain:(NSString *)domainStr;

/**
 Connect to router
 @param ssid  Routers Name
 @param pws  Router password(password is more than 8 bits)
 */
- (void)connectRouterSsid:(NSString *)ssid password:(NSString *)pws;


//Request to update the effect file(before sending the file, send this request order first, with this step, the device will turn off the blue tooth.If Bluetooth is not turned off, it will affect the transmission speed.)
- (void)requestUploadDevice;

//Send file finished(update playlist), sending this order will update playlist and open the Bluetooth at the same time.
- (void)sendFileEnd;

//Restart command(Restart after changing WiFi name and password)   =======  Only new device available
- (void)restartCommand;


//Start device update. Path to upgrade package.      =======  Only new device available
/** Notice: 1. Send upgrade package to device after calling,can use the agent way ‘didUpdataProgress’ to get upload progress.
            2. Upload successfully will automatically restart the device,please remind user, Upload successful, wait for equipment restart upgrade, while upgrading, do not cut power.
            3. Upload completed proxy method: didUploadToDeviceResult
 */
- (void)updataDeviceWithBinPath:(NSString *)path;

//Gets the currently displaying file        =======  Only new device available
/**  1.When fileName is nil, in order to get the current displaying file, Returns by proxy.
     2.When fileName is not nil, device will display this file immediately, (fileName is the file name).
     3.The fileName must be the file extension in the device, otherwise the device will display “video”.
 */
- (void)getCurrentPlayingFileName:(NSString *)nameStr;

//On and off, Power is nil, the statement is to get open and off. “1”means On, “0” means Off =======  Only Z3H device available
//On and Off only available in the model version Z3H, for Z3S model, whatever it sends, it always returns to boot.
- (void)devicePower:(NSString *)power;

//Brightness adjustment, the range is from 0 to 100         =======  Only new device available
//when luminance is nil, means to get the value of the brightness.
//when luminance is save, means to save the current brightness.
//Note: If the brightness is not saved after adjusting, the brightness will be restored after the power outage is restarted.
- (void)luminanceController:(NSString *)luminance;

//Angle adjustment, the range is from 0 to 360        =======  Only new device available
//When Angle is nil, is to get the Angle Value.
//When Angle is save, is to save the current Angle.
//Notice: 1. After adjusting the angle, if not saved, the power cut will restore the previous angle after restarting
//        2. The Z3S device, degree 0 means angle is positive.
- (void)angleController:(NSString *)angle;


@end



@protocol ZXBCommandDelegate <NSObject>

@required
//Receive device information
//StatusCode:Normal  2.Not Working  3. Unable to connect
//Version:Software version number
//HardVersion:Hardware version number
//DeviceMacAdd:Device MAC address
//Power:Switch on and off status
//DisplayImageId:Current display files
- (void)didReceivedInfo:(NSString *)info;

//Disconnected
- (void)didDisconnected;


@optional

//Formatting results    1. Formatting Success   2. Device exception  3. Not Found the SD card
- (void)didFormatResult:(int)code;

//Set Name Result
- (void)didSetWiFiNameSuccess;

//Set Password Result
- (void)didSetWiFiPasswordSuccess;

//Binding User Agent    1. Succeed  3. Failed, Device exception
- (void)didBingUsersResult:(int)code;

//Name and password sent to device
- (void)didConnectRouter;

//Update Display
//1. Can be updated
//2. No need to update, the file already existed
//3. Device exception can not be updated
- (void)didUploadResult:(int)code;

//Device returns update end command  1. Succeed  3. Failed, Device exception
- (void)didSendEndResult:(int)code;

//Device restart results     1. Succeed    3. Failed
- (void)didRestartResult:(int)code;

//Upload complete progress
- (void)didUpdataProgress:(float)progress;

//The Results of updatings file
//1.Succeed, Waiting for device restart upgrade, while upgrading, do not cut power.
//2.Upgrade file does not exist or failed to check
//3.Device exception
- (void)didUploadToDeviceResult:(int)code;

//Return to the currently displaying file
- (void)didCurrentPlayFileName:(NSString *)nameStr;

//Back to on and off result
- (void)didPowerResult:(BOOL)power;

//Return Brightness
//If the return value is always 100, means the device hardware is not supported
- (void)didLuminanceResult:(NSString *)luminance;

//Return Angle
//If the returned value range is not 0 ~ 360, the device hardware is not supported
- (void)didAngleResult:(NSString *)angle;



@end








