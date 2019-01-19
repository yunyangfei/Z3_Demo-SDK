//
//  ZXBFileManager.h
//  ZXBZ3Lib
//
//  Created by 刘清 on 2018/12/15.
//  Copyright © 2018 WIIKK. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZXBFileDelegate;
@interface ZXBFileManager : NSObject

@property (strong) id<ZXBFileDelegate> delegate;

//获取设备文件列表
- (void)getDeviceFileList;

//创建一个路径
- (void)creatDirectoryPath:(NSString *)path;

//上传文件
- (void)uploadFilePath:(NSString *)path;

//删除文件
- (void)deleteFileAtName:(NSString *)Name;

//取消请求
- (void)stopAndCancelAllRequests;


@end


@protocol ZXBFileDelegate <NSObject>

@optional

//请求列表完成
- (void)didCompleteListRequest:(NSArray *)list;

//创建目录完成
- (void)didCompleteCreateDirectoryRequest;

//完成了删除
- (void)didCompleteDeleteRequest;

//完成进度
- (void)didCompleteProgress:(float)progress;

//上传完成
- (void)didCompleteUploadRequest;

//下载完成
//- (void)didCompleteDownloadRequest;

//请求失败
- (void)didFailRequestError:(NSError *)error;

//下载文件写入本地失败
- (void)didFailWritingFileAtPath:(NSString *)path error:(NSError *)error;



@end

