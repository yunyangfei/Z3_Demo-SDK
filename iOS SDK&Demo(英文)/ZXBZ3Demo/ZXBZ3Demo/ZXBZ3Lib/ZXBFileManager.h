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

//Get Device File List
- (void)getDeviceFileList;

//Create a Path
- (void)creatDirectoryPath:(NSString *)path;

//Upload File
- (void)uploadFilePath:(NSString *)path;

//Delete File
- (void)deleteFileAtName:(NSString *)Name;

//Cancel request
- (void)stopAndCancelAllRequests;


@end


@protocol ZXBFileDelegate <NSObject>

@optional

//Request list done
- (void)didCompleteListRequest:(NSArray *)list;

//Create Directory Done
- (void)didCompleteCreateDirectoryRequest;

//Delete Done
- (void)didCompleteDeleteRequest;

//Completion Progress
- (void)didCompleteProgress:(float)progress;

//Upload Done
- (void)didCompleteUploadRequest;

//Download Done
//- (void)didCompleteDownloadRequest;

//Request Failed
- (void)didFailRequestError:(NSError *)error;

//Download file to write locally failed
- (void)didFailWritingFileAtPath:(NSString *)path error:(NSError *)error;



@end

