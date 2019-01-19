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

@interface FileController () <ZXBCommandDelegate, ZXBFileDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) ZXBSocketCommand *socketCommand;
@property (nonatomic, strong) ZXBFileManager *fileManager;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, copy) NSString *fileName;//临时文件名

@end

@implementation FileController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.socketCommand.delegate = self;
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
    
    //先发送请求更新效果文件命令, 之后才能进行文件操作
    [self.socketCommand requestUploadDevice:self.infoDic[@"DisplayImageId"]];
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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"tupian" ofType:@"jpg"];
    //self.fileName = [path lastPathComponent];
    [self.fileManager uploadFilePath:path];
    
}
//上传视频
- (void)rightBtnTwoAction
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"shiping" ofType:@"mp4"];
    //self.fileName = [path lastPathComponent];
    [self.fileManager uploadFilePath:path];
}
//返回播放
- (void)leftBtnAction
{
    //可先将代理置为nil
    self.socketCommand.delegate = nil;
    [self.socketCommand deinit];
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
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeakSelf(self);
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        self.fileName = self.dataArr[indexPath.row];
        [weakself.fileManager deleteFileAtName:self.fileName];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    return @[deleteAction];
}




#pragma mark - ZXBCommandDelegate
- (void)didReceivedInfo:(NSString *)info{
    self.infoDic = [Tools getURLParameters:info];
    NSLog(@">>>>%@", self.infoDic);
}

- (void)didDisconnected{
    NSLog(@">>>>设备断开连接");
}

//更新显示      1->可以更新；2->不需要更新，已经有此效果文件；3->设备异常不能更新
- (void)didUploadResult:(int)code{
    if (code == 1){
        //进行文件操作:获取设备文件列表
        [self.fileManager getDeviceFileList];
    }
}


#pragma mark - ZXBFileDelegate
//请求列表完成
- (void)didCompleteListRequest:(NSArray *)list{
    NSLog(@">>>>设备文件列表:%@", list);
    [self.dataArr removeAllObjects];
    [self.dataArr addObjectsFromArray:list];
    [self.tableView reloadData];
}

//完成了删除
- (void)didCompleteDeleteRequest{
    NSLog(@">>>>>完成了删除");
    if (self.fileName){
        [self.dataArr removeObject:self.fileName];
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
}

//上传完成
- (void)didCompleteUploadRequest{
    NSLog(@">>>>>完成了上传");
    [self.fileManager getDeviceFileList];
    if ([self.infoDic[@"Version"] intValue] >= 200){
        //发送立马更新命令,可以不管结果
        [self.socketCommand sendFileEnd];
    }
}

//请求失败
- (void)didFailRequestError:(NSError *)error{
    NSLog(@">>>>>请求失败了====Error:%@", error);
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
