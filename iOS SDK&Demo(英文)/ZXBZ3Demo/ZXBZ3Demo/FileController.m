//
//  FileController.m
//  ZXBZ3Demo
//
//  Created by 刘清 on 2018/12/15.
//  Copyright © 2018 WIIKK. All rights reserved.
//

#import "FileController.h"
#import "ZXBSocketCommand.h"
#import "ZXBFileManager.h"
#import "Tools.h"
#import "WSProgressHUD.h"

@interface FileController () <ZXBCommandDelegate, ZXBFileDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) ZXBSocketCommand *socketCommand;
@property (nonatomic, strong) ZXBFileManager *fileManager;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, copy) NSString *filePath;//Temporary File Path
@property (nonatomic, copy) NSString *deleteName;//File name to delete
@property (nonatomic, strong) WSProgressHUD *hud;

@end

@implementation FileController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.socketCommand.delegate = self;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.socketCommand.delegate = nil;//First delegate is nil, otherwise it will bounce out of the project.
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers==nil || [viewControllers indexOfObject:self]==NSNotFound){
        //pop Operation
        self.socketCommand = nil;
        [self.fileManager stopAndCancelAllRequests];
    }
    //[self stopTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"File Operations";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back to Play" style:UIBarButtonItemStylePlain target:self action:@selector(leftBtnAction)];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self creatBtn];
    [self tableView];
    
    
 /**
 Notice: 1. Here the Z3 device is different as the Z3S operation, Z3_480 is the same as the Z3S operation.
         2. We distinguish Z3 and Z3s according to the software version. The software version less than 200 is Z3.
         3. Z3s can get the file list directly from the device, but before sending the file need request an update order, during this step, the device will turn off Bluetooth, otherwise the transmission speed will be very slow.
         4. The Z3 device needs to request an update first, otherwise the file list in the device can not be obtained.
 */
    if ([self.infoDic[@"Version"] integerValue] >= 200){
        //Z3s device, Go directly to the file list
        [self showHudLoadingString:@"Loading"];
        [self.fileManager getDeviceFileList];
    }else{
        //Z3 device, first request to update the effect file
        [self showHudLoadingString:@"Loading"];
        [self.socketCommand requestUploadDevice];
    }
}

- (ZXBSocketCommand *)socketCommand
{
    if (!_socketCommand){
        _socketCommand = [[ZXBSocketCommand defaultSocket] initWithSocket];
    }
    return _socketCommand;
}

- (ZXBFileManager *)fileManager
{
    if (!_fileManager){
        _fileManager = [[ZXBFileManager alloc] init];
        _fileManager.delegate = self;
    }
    return _fileManager;
}

- (NSMutableArray *)dataArr
{
    if (!_dataArr){
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)creatBtn
{
    NSArray *titleArr = @[@"Sending Pictures", @"Sending Videos"];
    for (int i=0; i<titleArr.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i*KScreenWidth/2, 0, KScreenWidth/2, 34)];
        btn.frame = CGRectMake(i*KScreenWidth/2, 0, KScreenWidth/2, 40);
        [btn setTitle:titleArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
        if (i){
            [btn addTarget:self action:@selector(uploadVideoAction) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [btn addTarget:self action:@selector(uploadImageAction) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.view addSubview:btn];
    }
}

- (UITableView *)tableView
{
    if (!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.frame = CGRectMake(0, 40, KScreenWidth, KScreenHeight-kNavBarHeight-34);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

//Upload Image
- (void)uploadImageAction
{
    self.filePath = [[NSBundle mainBundle] pathForResource:@"pic" ofType:@"jpg"];
    if ([self.infoDic[@"Version"] integerValue] >= 200){
        //Z3S, first request to update the effect file, turn off Bluetooth
        [self showHudLoadingString:@"Loading"];
        [self.socketCommand requestUploadDevice];
    }else{
        //Z3 device, entered file operation, uploaded directly
        [self showHudLoadingString:@"Loading"];
        [self.fileManager uploadFilePath:self.filePath];
    }
}
//Upload video
- (void)uploadVideoAction
{
    self.filePath = [[NSBundle mainBundle] pathForResource:@"hamburger" ofType:@"mp4"];
    if ([self.infoDic[@"Version"] integerValue] >= 200){
        //Z3S, first request to update the effect file, turn off Bluetooth
        [self showHudLoadingString:@"Loading"];
        [self.socketCommand requestUploadDevice];
    }else{
        //Z3 device, entered file operation, uploaded directly
        [self showHudLoadingString:@"Loading"];
        [self.fileManager uploadFilePath:self.filePath];
    }
}
//Back to Play
- (void)leftBtnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- tableView的代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = self.dataArr[indexPath.row];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.socketCommand getCurrentPlayingFileName:self.dataArr[indexPath.row]];
}
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeakSelf(self);
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [weakself showHudLoadingString:@"Loading"];
        self.deleteName = self.dataArr[indexPath.row];
        [weakself.fileManager deleteFileAtName:self.deleteName];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    return @[deleteAction];
}




#pragma mark - ZXBCommandDelegate
- (void)didReceivedInfo:(NSString *)info{
    [self hideHud];
    self.infoDic = [Tools getURLParameters:info];
    NSLog(@">>>>%@", self.infoDic);
}

- (void)didDisconnected{
    [self hideHud];
    NSLog(@">>>>Device Disconnected ");
}

//Update Display
//1-> Can be updated;
//2-> No need to update, the file already existed;
//3-> Device exception can not be updated
- (void)didUploadResult:(int)code{
    if (code == 1){
        if ([self.infoDic[@"Version"] integerValue] >= 200){
            //Z3S, start uploading files
            if (self.filePath){
                [self.fileManager uploadFilePath:self.filePath];
            }
        }else{
            //Z3 Device, file operation: get device file list
            [self.fileManager getDeviceFileList];
        }
    }else{
        [self hideHud];
    }
}
//Return to the currently displaying file
- (void)didCurrentPlayFileName:(NSString *)nameStr
{
    NSLog(@">>>>playing:%@", nameStr);
}


#pragma mark - ZXBFileDelegate
//Request list done
- (void)didCompleteListRequest:(NSArray *)list{
    NSLog(@">>>>Device file list:%@", list);
    [self hideHud];
    [self.dataArr removeAllObjects];
    [self.dataArr addObjectsFromArray:list];
    [self.tableView reloadData];
}

//Delete done
- (void)didCompleteDeleteRequest{
    NSLog(@">>>>>Delete done");
    [self hideHud];
    if (self.deleteName){
        [self.dataArr removeObject:self.deleteName];
    }
    [self.tableView reloadData];
    if ([self.infoDic[@"Version"] intValue] >= 200){
        //Send an immediate update command. You can ignore the result.
        [self.socketCommand sendFileEnd];
    }
}

//Progress towards completion
- (void)didCompleteProgress:(float)progress{
    NSLog(@"Progress====>%f", progress);
    [self showHudLoadingString:[NSString stringWithFormat:@"Uploading%d%%", (int)(progress*100)]];
}

//Upload completed
- (void)didCompleteUploadRequest{
    NSLog(@">>>>>Upload completed");
    [self.fileManager getDeviceFileList];
    if ([self.infoDic[@"Version"] intValue] >= 200){
        //Send an immediate update command. You can ignore the result.
        [self.socketCommand sendFileEnd];
    }else{
        [self hideHud];
    }
}

//Request Failed
- (void)didFailRequestError:(NSError *)error{
    NSLog(@">>>>>Request Failed====Error:%@", error);
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
