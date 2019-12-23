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

@property (nonatomic, copy) NSString *filePath;//临时文件路径
@property (nonatomic, copy) NSString *deleteName;//要删除的文件名
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
    self.socketCommand.delegate = nil;//先delegate为nil，否则会弹出disconnect
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers==nil || [viewControllers indexOfObject:self]==NSNotFound){
        //pop操作
        self.socketCommand = nil;
        [self.fileManager stopAndCancelAllRequests];
    }
    //[self stopTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"文件操作";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self tableView];
    UIBarButtonItem *oneBtn = [[UIBarButtonItem alloc] initWithTitle:@"发图片" style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnOneAction)];
    UIBarButtonItem *twoBtn = [[UIBarButtonItem alloc] initWithTitle:@"发视频" style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnTwoAction)];
    self.navigationItem.rightBarButtonItems = @[twoBtn, oneBtn];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回播放" style:UIBarButtonItemStylePlain target:self action:@selector(leftBtnAction)];
    
    /**
     注意:1.此处Z3设备和Z3s操作有所区别, Z3_480和Z3s操作一样
         2.我们根据软件版本来判断Z3和Z3s, 软件版本小于200的为Z3
         3.Z3s可直接获取到设备内的文件列表, 但是发送文件前先调用请求更新的命令, 设备会关掉蓝牙, 否则传输速度很慢.
         4.Z3设备需要先调用请求更新的命令, 否则获取不到设备内的文件列表.
    */
    if ([self.infoDic[@"Version"] integerValue] >= 200){
        //Z3s, 直接去文件列表
        [self showHudLoadingString:@"加载中"];
        [self.fileManager getDeviceFileList];
    }else{
        //Z3设备, 先请求更新效果文件
        [self showHudLoadingString:@"加载中"];
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

- (UITableView *)tableView
{
    if (!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-kNavBarHeight);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

//上传图片
- (void)rightBtnOneAction
{
    self.filePath = [[NSBundle mainBundle] pathForResource:@"pic" ofType:@"jpg"];
    if ([self.infoDic[@"Version"] integerValue] >= 200){
        //Z3s, 先请求更新效果文件, 关掉蓝牙
        [self showHudLoadingString:@"加载中"];
        [self.socketCommand requestUploadDevice];
    }else{
        //Z3设备, 已经进入文件操作, 直接上传
        [self showHudLoadingString:@"加载中"];
        [self.fileManager uploadFilePath:self.filePath];
    }
}
//上传视频
- (void)rightBtnTwoAction
{
    self.filePath = [[NSBundle mainBundle] pathForResource:@"hamburger" ofType:@"mp4"];
    if ([self.infoDic[@"Version"] integerValue] >= 200){
        //Z3s, 先请求更新效果文件, 关掉蓝牙
        [self showHudLoadingString:@"加载中"];
        [self.socketCommand requestUploadDevice];
    }else{
        //Z3设备, 已经进入文件操作, 直接上传
        [self showHudLoadingString:@"加载中"];
        [self.fileManager uploadFilePath:self.filePath];
    }
}
//返回播放
- (void)leftBtnAction
{
    [self.socketCommand sendFileEnd];
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
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [weakself showHudLoadingString:@"加载中"];
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
    NSLog(@">>>>设备断开连接");
}

//更新显示      1->可以更新；2->不需要更新，已经有此效果文件；3->设备异常不能更新
- (void)didUploadResult:(int)code{
    if (code == 1){
        if ([self.infoDic[@"Version"] integerValue] >= 200){
            //Z3s, 开始上传文件
            if (self.filePath){
                [self.fileManager uploadFilePath:self.filePath];
            }
        }else{
            //Z3设备, 进行文件操作:获取设备文件列表
            [self.fileManager getDeviceFileList];
        }
    }else{
        [self hideHud];
    }
}
//返回当前正在播放的文件
- (void)didCurrentPlayFileName:(NSString *)nameStr
{
    NSLog(@">>>>正在播放:%@", nameStr);
}


#pragma mark - ZXBFileDelegate
//请求列表完成
- (void)didCompleteListRequest:(NSArray *)list{
    NSLog(@">>>>设备文件列表:%@", list);
    [self hideHud];
    [self.dataArr removeAllObjects];
    [self.dataArr addObjectsFromArray:list];
    [self.tableView reloadData];
}

//完成了删除
- (void)didCompleteDeleteRequest{
    NSLog(@">>>>>完成了删除");
    [self hideHud];
    if (self.deleteName){
        [self.dataArr removeObject:self.deleteName];
    }
    [self.tableView reloadData];
    if ([self.infoDic[@"Version"] intValue] >= 200){
        //发送立马更新命令,可以不管结果
        [self.socketCommand sendFileEnd];
    }
}

//完成进度
- (void)didCompleteProgress:(float)progress{
    NSLog(@"进度====>%f", progress);
    [self showHudLoadingString:[NSString stringWithFormat:@"上传中%d%%", (int)(progress*100)]];
}

//上传完成
- (void)didCompleteUploadRequest{
    NSLog(@">>>>>完成了上传");
    [self.fileManager getDeviceFileList];
    if ([self.infoDic[@"Version"] intValue] >= 200){
        //发送立马更新命令,可以不管结果
        [self.socketCommand sendFileEnd];
    }else{
        [self hideHud];
    }
}

//请求失败
- (void)didFailRequestError:(NSError *)error{
    NSLog(@">>>>>请求失败了====Error:%@", error);
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
